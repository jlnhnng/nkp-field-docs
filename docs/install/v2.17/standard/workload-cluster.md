# Create a workload cluster

> Tested with NKP 2.17.1

This guide creates an NKP-managed workload cluster on Nutanix AHV.

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
export NUTANIX_MACHINE_TEMPLATE_IMAGE_NAME=nkp-ubuntu-24.04-release-cis-1.34.3.qcow2

export CONTROL_PLANE_ENDPOINT_IP=192.0.2.30
export LB_IP_RANGE=192.0.2.31-192.0.2.40
export REGISTRY_MIRROR_URL=registry.example.com/docker.io

read -r -s -p "Prism Central password: " NUTANIX_PASSWORD
export NUTANIX_PASSWORD
echo
```

## Create the cluster

```bash
nkp create cluster nutanix -c "${CLUSTER_NAME}" \
  --namespace "${WORKSPACE_NAME}" \
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
  --control-plane-vcpus 4 \
  --control-plane-memory 16 \
  --worker-replicas 3 \
  --worker-vcpus 8 \
  --worker-memory 32 \
  --kubeconfig "${MANAGEMENT_KUBECONFIG}"
```

## Verify the cluster

```bash
kubectl --kubeconfig "${MANAGEMENT_KUBECONFIG}" \
  get clusters,machines -n "${WORKSPACE_NAME}"
kubectl --kubeconfig "${CLUSTER_NAME}.conf" get nodes
```

## Next step

[Create a project](project.md).
