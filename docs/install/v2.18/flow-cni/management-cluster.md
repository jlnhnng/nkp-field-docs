# Create a management cluster with Flow CNI

> Tested with NKP 2.18.0

This guide replaces the default Cilium CNI with Nutanix Flow CNI
(OVN-Kubernetes). The cluster manifest is generated, modified, and then applied.

## Before you begin

You need:

- a [prepared bootstrap node](../../bootstrap-node/index.md);
- the NKP 2.18.0 bundle and supported node image;
- `yq`, Docker, and `kubectl`;
- non-overlapping pod, service, node, and load balancer networks;
- the supported Flow CNI chart version and image-registry token.

## Install the NKP CLI

```bash
tar -xzvf nkp-bundle_v2.18.0_linux_amd64.tar.gz
sudo install -m 0755 ./nkp-v2.18.0/cli/nkp /usr/local/bin/nkp
docker load --input nkp-v2.18.0/konvoy-bootstrap-image-v2.18.0.tar
```

## Configure the environment

```bash
export CLUSTER_NAME=nkp-mgmt-cluster

export NUTANIX_USER=admin
export NUTANIX_ENDPOINT=pc.example.com
export NUTANIX_PORT=9440
export NUTANIX_PRISM_ELEMENT_CLUSTER_NAME=PE-CLUSTER
export NUTANIX_SUBNET_NAME=PRIMARY-NETWORK
export NUTANIX_STORAGE_CONTAINER_NAME=CONTAINER
export NUTANIX_MACHINE_TEMPLATE_IMAGE_NAME=nkp-rocky-9.7-release-cis-1.35.2.qcow2

export CONTROL_PLANE_ENDPOINT_IP=192.0.2.10
export LB_IP_RANGE=192.0.2.11-192.0.2.20
export REGISTRY_MIRROR_URL=registry.example.com/docker.io

export POD_CIDR=172.20.0.0
export SERVICE_CIDR=172.21.0.0
export FLOW_CHART_VERSION=1.3.0
export DOCKER_FLOW_TOKEN="REPLACE_WITH_FLOW_IMAGE_TOKEN"

read -r -s -p "Prism Central password: " NUTANIX_PASSWORD
export NUTANIX_PASSWORD
echo
```

## Generate the cluster manifest

```bash
nkp create cluster nutanix -c "${CLUSTER_NAME}" \
  --endpoint "https://${NUTANIX_ENDPOINT}:${NUTANIX_PORT}" \
  --insecure \
  --control-plane-endpoint-ip "${CONTROL_PLANE_ENDPOINT_IP}" \
  --kubernetes-service-load-balancer-ip-range "${LB_IP_RANGE}" \
  --control-plane-vm-image "${NUTANIX_MACHINE_TEMPLATE_IMAGE_NAME}" \
  --control-plane-prism-element-cluster "${NUTANIX_PRISM_ELEMENT_CLUSTER_NAME}" \
  --control-plane-subnets "${NUTANIX_SUBNET_NAME}" \
  --worker-vm-image "${NUTANIX_MACHINE_TEMPLATE_IMAGE_NAME}" \
  --worker-prism-element-cluster "${NUTANIX_PRISM_ELEMENT_CLUSTER_NAME}" \
  --worker-subnets "${NUTANIX_SUBNET_NAME}" \
  --csi-storage-container "${NUTANIX_STORAGE_CONTAINER_NAME}" \
  --registry-mirror-url "https://${REGISTRY_MIRROR_URL}" \
  --skip-preflight-checks=Registry \
  --control-plane-replicas 3 \
  --worker-replicas 3 \
  --kubernetes-pod-network-cidr "${POD_CIDR}/16" \
  --kubernetes-service-cidr "${SERVICE_CIDR}/16" \
  --self-managed \
  --dry-run -o yaml > "${CLUSTER_NAME}.yaml"
```

## Remove the default CNI

```bash
CLUSTER_UUID=$(yq eval \
  '(select(.kind == "Cluster") | .metadata.annotations."caren.nutanix.com/cluster-uuid")' \
  "${CLUSTER_NAME}.yaml")

yq eval \
  '(select(.kind == "Cluster") | del(.spec.topology.variables[0].value.addons.cni)) // select(.kind != "Cluster")' \
  "${CLUSTER_NAME}.yaml" > "${CLUSTER_NAME}-flow-cni.yaml"
```

Verify that `CLUSTER_UUID` is not empty and that the generated Cluster no longer
contains the default CNI configuration.

## Add the Flow CNI HelmChartProxy

```bash
DOCKER_FLOW_TOKEN_BASE64=$(printf "svcpubflowcni:%s" "${DOCKER_FLOW_TOKEN}" | base64)

cat >> "${CLUSTER_NAME}-flow-cni.yaml" <<EOF
---
apiVersion: addons.cluster.x-k8s.io/v1alpha1
kind: HelmChartProxy
metadata:
  name: flow-cni-${CLUSTER_UUID}
  namespace: default
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

## Apply the manifest

```bash
kubectl apply -f "${CLUSTER_NAME}-flow-cni.yaml" --server-side=true
```

## Verify Flow CNI

```bash
kind get kubeconfig --name konvoy-capi-bootstrapper > bootstrap-cluster.conf
kubectl --kubeconfig bootstrap-cluster.conf get helmchartproxy -A
kubectl --kubeconfig bootstrap-cluster.conf get clusters,machines -A

kubectl --kubeconfig "${CLUSTER_NAME}.conf" get nodes
kubectl --kubeconfig "${CLUSTER_NAME}.conf" get pods -n flow-cni-system
```

!!! tip "Field note: choose the CNI before creation"
    Replacing the CNI on a running cluster is disruptive. Treat the CNI as a
    cluster-lifecycle decision.

## Next step

[Create a workspace](workspace.md).
