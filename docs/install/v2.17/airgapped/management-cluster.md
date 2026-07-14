# Create an air-gapped management cluster

> Tested with NKP 2.17.1

This guide creates a management cluster whose nodes cannot access public
registries or package repositories.

## Before you begin

You need a [prepared bootstrap node](../../bootstrap-node/index.md), the NKP
2.17.1 air-gapped bundle, a supported offline node image, reserved IP addresses,
internal infrastructure services, and an image-distribution choice.

## Install the bundle

```bash
mkdir -p "$HOME/airgap-nkp"
cd "$HOME/airgap-nkp"
tar -xzvf nkp-air-gapped-bundle_v2.17.1_linux_amd64.tar.gz
cd nkp-v2.17.1

sudo install -m 0755 ./cli/nkp /usr/local/bin/nkp
docker load -i konvoy-bootstrap-image-v2.17.1.tar
docker load -i nkp-image-builder-image-v2.17.1.tar
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
export NUTANIX_MACHINE_TEMPLATE_IMAGE_NAME=nkp-ubuntu-24.04-1.34.3-YYYYMMDDHHMMSS

export CONTROL_PLANE_ENDPOINT_IP=192.0.2.10
export LB_IP_RANGE=192.0.2.11-192.0.2.20
export SSH_PUBLIC_KEY_FILE="$HOME/.ssh/id_ed25519.pub"

read -r -s -p "Prism Central password: " NUTANIX_PASSWORD
export NUTANIX_PASSWORD
echo
```

## Build an offline node image

Skip this step if a supported image is already available:

```bash
export OS=ubuntu-24.04
export OS_BUNDLE_DIR=kib/artifacts
export BASE_IMAGE=ubuntu-24.04-server-cloudimg-amd64.img

nkp create package-bundle \
  --artifacts-directory "${OS_BUNDLE_DIR}" \
  "${OS}"

nkp create image nutanix "${OS}" \
  --endpoint "${NUTANIX_ENDPOINT}" \
  --cluster "${NUTANIX_PRISM_ELEMENT_CLUSTER_NAME}" \
  --subnet "${NUTANIX_SUBNET_NAME}" \
  --source-image "${BASE_IMAGE}" \
  --artifacts-directory "${OS_BUNDLE_DIR}"
```

## Choose the registry

Use the built-in registry by passing `--bundle`, or push the Konvoy, Kommander,
and application bundles to an external private registry with `nkp push bundle`.

## Create the cluster

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
  --ssh-public-key-file "${SSH_PUBLIC_KEY_FILE}" \
  --control-plane-replicas 3 \
  --worker-replicas 3 \
  --bundle=./container-images/*.tar \
  --airgapped \
  --self-managed
```

## Verify the cluster

```bash
kubectl --kubeconfig "${MANAGEMENT_KUBECONFIG}" get nodes
kubectl --kubeconfig "${MANAGEMENT_KUBECONFIG}" get pods -A
```

## Next step

[Create a workspace](workspace.md).
