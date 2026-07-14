# Create an air-gapped management cluster

> Tested with NKP 2.18.0

This guide creates a management cluster whose nodes cannot access public
registries or package repositories.

## Before you begin

You need:

- a [prepared bootstrap node](../../bootstrap-node/index.md);
- Prism Central 7.5 or later and AOS 7.5 or later;
- the NKP 2.18.0 air-gapped bundle;
- an offline-capable NKP node image in Prism Central;
- reserved cluster IP addresses and internal DNS, NTP, and storage services;
- either the NKP built-in infrastructure registry or an external private
  registry.

Transfer all required artifacts into the restricted environment before removing
bootstrap-host internet access.

## Install the air-gapped bundle

```bash
mkdir -p "$HOME/airgap-nkp"
cd "$HOME/airgap-nkp"

tar -xzvf nkp-air-gapped-bundle_v2.18.0_linux_amd64.tar.gz
cd nkp-v2.18.0

sudo install -m 0755 ./cli/nkp /usr/local/bin/nkp
docker load -i konvoy-bootstrap-image-v2.18.0.tar
docker load -i nkp-image-builder-image-v2.18.0.tar
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
export NUTANIX_MACHINE_TEMPLATE_IMAGE_NAME=nkp-ubuntu-24.04-1.35.2-YYYYMMDDHHMMSS

export CONTROL_PLANE_ENDPOINT_IP=192.0.2.10
export LB_IP_RANGE=192.0.2.11-192.0.2.20
export SSH_PUBLIC_KEY_FILE="$HOME/.ssh/id_ed25519.pub"

read -r -s -p "Prism Central password: " NUTANIX_PASSWORD
export NUTANIX_PASSWORD
echo
```

## Build an offline node image

Skip this section when a supported offline-capable NKP image is already in Prism
Central.

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

Record the generated Prism Central image name in
`NUTANIX_MACHINE_TEMPLATE_IMAGE_NAME`.

## Choose the registry

### Built-in infrastructure registry

No registry preparation is required. Pass the container image bundles to
`nkp create cluster` in the next section.

### External private registry

Configure the registry and push each bundle:

```bash
export REGISTRY_URL=https://registry.example.com/nkp
export REGISTRY_USERNAME=admin
export REGISTRY_CACERT="$HOME/certs/ca-chain.pem"

read -r -s -p "Registry password: " REGISTRY_PASSWORD
export REGISTRY_PASSWORD
echo

nkp push bundle \
  --bundle ./container-images/konvoy-image-bundle-v2.18.0.tar \
  --to-registry "${REGISTRY_URL}" \
  --to-registry-username "${REGISTRY_USERNAME}" \
  --to-registry-password "${REGISTRY_PASSWORD}" \
  --to-registry-ca-cert-file "${REGISTRY_CACERT}"

nkp push bundle \
  --bundle ./container-images/kommander-image-bundle-v2.18.0.tar \
  --to-registry "${REGISTRY_URL}" \
  --to-registry-username "${REGISTRY_USERNAME}" \
  --to-registry-password "${REGISTRY_PASSWORD}" \
  --to-registry-ca-cert-file "${REGISTRY_CACERT}"
```

Push the application repository bundle using the same registry settings.

## Create the cluster with the built-in registry

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

For an external registry, replace `--bundle` with the applicable
`--registry-mirror-*` and `--registry-*` options.

## Verify the cluster

```bash
kubectl --kubeconfig "${MANAGEMENT_KUBECONFIG}" get nodes
kubectl --kubeconfig "${MANAGEMENT_KUBECONFIG}" get pods -A
nkp get dashboard --kubeconfig "${MANAGEMENT_KUBECONFIG}"
```

Check for image-pull errors before removing transferred bundles.

!!! tip "Field note: prove the offline path"
    Block public registry access during validation. A successful installation
    while public services remain reachable does not prove the mirror is complete.

## Next step

[Create a workspace](workspace.md).
