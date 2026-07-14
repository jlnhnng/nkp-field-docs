# Create a workload cluster with Flow CNI

> Tested with NKP 2.18.0

Generate the workload-cluster manifest, remove Cilium, and add a Flow CNI
`HelmChartProxy` before applying it.

## Configure the environment

```bash
export MANAGEMENT_KUBECONFIG="$HOME/nkp-mgmt-cluster.conf"
export WORKSPACE_NAME=dev-workspace
export CLUSTER_NAME=nkp-dev-cluster

export NUTANIX_USER=admin
export NUTANIX_ENDPOINT=pc.example.com
export NUTANIX_PORT=9440
export NUTANIX_PRISM_ELEMENT_CLUSTER_NAME=PE-CLUSTER
export NUTANIX_SUBNET_NAME=PRIMARY-NETWORK
export NUTANIX_STORAGE_CONTAINER_NAME=CONTAINER
export NUTANIX_MACHINE_TEMPLATE_IMAGE_NAME=nkp-rocky-9.7-release-cis-1.35.2.qcow2

export CONTROL_PLANE_ENDPOINT_IP=192.0.2.30
export LB_IP_RANGE=192.0.2.31-192.0.2.40
export POD_CIDR=172.22.0.0
export SERVICE_CIDR=172.23.0.0
export FLOW_CHART_VERSION=1.3.0
export DOCKER_FLOW_TOKEN="REPLACE_WITH_FLOW_IMAGE_TOKEN"

read -r -s -p "Prism Central password: " NUTANIX_PASSWORD
export NUTANIX_PASSWORD
echo
```

Use pod and service networks that do not overlap with any existing cluster or
node subnet.

## Generate and modify the manifest

Run the standard `nkp create cluster nutanix` command with these additional
arguments:

```bash
--namespace "${WORKSPACE_NAME}" \
--kubernetes-pod-network-cidr "${POD_CIDR}/16" \
--kubernetes-service-cidr "${SERVICE_CIDR}/16" \
--kubeconfig "${MANAGEMENT_KUBECONFIG}" \
--dry-run -o yaml > "${CLUSTER_NAME}.yaml"
```

Use all Nutanix infrastructure, node image, sizing, endpoint, and registry
arguments from the [standard workload-cluster guide](../standard/workload-cluster.md).

Remove the default CNI and obtain the generated cluster UUID:

```bash
CLUSTER_UUID=$(yq eval \
  '(select(.kind == "Cluster") | .metadata.annotations."caren.nutanix.com/cluster-uuid")' \
  "${CLUSTER_NAME}.yaml")

yq eval \
  '(select(.kind == "Cluster") | del(.spec.topology.variables[0].value.addons.cni)) // select(.kind != "Cluster")' \
  "${CLUSTER_NAME}.yaml" > "${CLUSTER_NAME}-flow-cni.yaml"
```

## Add Flow CNI

```bash
DOCKER_FLOW_TOKEN_BASE64=$(printf "svcpubflowcni:%s" "${DOCKER_FLOW_TOKEN}" | base64)

cat >> "${CLUSTER_NAME}-flow-cni.yaml" <<EOF
---
apiVersion: addons.cluster.x-k8s.io/v1alpha1
kind: HelmChartProxy
metadata:
  name: flow-cni-${CLUSTER_UUID}
  namespace: ${WORKSPACE_NAME}
spec:
  clusterSelector:
    matchLabels:
      cluster.x-k8s.io/cluster-name: ${CLUSTER_NAME}
  repoURL: https://nutanix.github.io/helm-releases/
  chartName: nutanix-flow-cni
  version: ${FLOW_CHART_VERSION}
  namespace: flow-cni-system
  options:
    waitForJobs: true
    wait: true
    timeout: 30m
    install:
      createNamespace: true
  valuesTemplate: |
    nutanix-core-flow-ovn-kubernetes:
      k8sAPIServer: "https://${CONTROL_PLANE_ENDPOINT_IP}:6443"
      podNetwork: "${POD_CIDR}/24"
      serviceNetwork: "${SERVICE_CIDR}"
    global:
      dockerConfigSecret:
        registry: docker.io
        auth: ${DOCKER_FLOW_TOKEN_BASE64}
        create: true
      imagePullSecretName: "flow-cni-secret"
    imagePullSecrets:
      - name: flow-cni-secret
EOF
```

## Apply and verify

```bash
kubectl --kubeconfig "${MANAGEMENT_KUBECONFIG}" \
  apply -f "${CLUSTER_NAME}-flow-cni.yaml" --server-side=true

kubectl --kubeconfig "${MANAGEMENT_KUBECONFIG}" \
  get clusters,machines -n "${WORKSPACE_NAME}"
kubectl --kubeconfig "${CLUSTER_NAME}.conf" get nodes
kubectl --kubeconfig "${CLUSTER_NAME}.conf" get pods -n flow-cni-system
```

## Next step

[Create a project](project.md).
