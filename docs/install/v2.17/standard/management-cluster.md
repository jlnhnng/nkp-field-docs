# Create a management cluster

> Tested with NKP 2.17.1

This guide creates a connected, self-managed NKP management cluster on Nutanix
AHV using a registry mirror.

## Before you begin

You need:

- a [prepared bootstrap node](../../bootstrap-node/index.md);
- Prism Central and AOS versions supported by NKP 2.17.1;
- the NKP 2.17.1 bundle;
- a supported NKP 2.17 node image;
- reserved control plane and load balancer IP addresses;
- Prism Element, subnet, storage container, and registry mirror details.

## Install the NKP CLI

```bash
tar -xzvf nkp-bundle_v2.17.1_linux_amd64.tar.gz
sudo install -m 0755 ./nkp-v2.17.1/cli/nkp /usr/local/bin/nkp
docker load --input nkp-v2.17.1/konvoy-bootstrap-image-v2.17.1.tar
nkp version
```

## Configure the environment

```bash
export CLUSTER_NAME=nkp-mgmt-cluster
export MANAGEMENT_KUBECONFIG="$HOME/${CLUSTER_NAME}.conf"

export NUTANIX_USER=admin
export NUTANIX_ENDPOINT=pc.example.com
export NUTANIX_PORT=9440
export NUTANIX_PRISM_ELEMENT_CLUSTER_NAME=PE-CLUSTER
export NUTANIX_SUBNET_NAME=PRIMARY-NETWORK
export NUTANIX_STORAGE_CONTAINER_NAME=CONTAINER
export NUTANIX_MACHINE_TEMPLATE_IMAGE_NAME=nkp-ubuntu-24.04-release-cis-1.34.3.qcow2

export CONTROL_PLANE_ENDPOINT_IP=192.0.2.10
export LB_IP_RANGE=192.0.2.11-192.0.2.20
export REGISTRY_MIRROR_URL=registry.example.com/docker.io

read -r -s -p "Prism Central password: " NUTANIX_PASSWORD
export NUTANIX_PASSWORD
echo
```

## Create the management cluster

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
  --control-plane-vcpus 4 \
  --control-plane-memory 16 \
  --worker-replicas 3 \
  --worker-vcpus 8 \
  --worker-memory 32 \
  --self-managed
```

Use trusted certificates and remove the insecure options in production.

## Verify the management cluster

```bash
kubectl --kubeconfig "${MANAGEMENT_KUBECONFIG}" get nodes
nkp get dashboard --kubeconfig "${MANAGEMENT_KUBECONFIG}"
```

Log in to the NKP UI and apply the required license.

## Next step

[Create a workspace](workspace.md).
