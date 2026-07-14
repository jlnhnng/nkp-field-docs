# Create a management cluster

> Tested with NKP 2.18.0

This guide creates a connected, self-managed NKP management cluster on Nutanix
AHV using a registry mirror.

## Before you begin

You need:

- a [prepared bootstrap node](../../bootstrap-node/index.md);
- Prism Central 7.5 or later and AOS 7.5 or later;
- the NKP 2.18.0 bundle;
- a supported NKP 2.18 node image in Prism Central;
- reserved control plane and load balancer IP addresses;
- Prism Element, subnet, and storage container names;
- registry mirror details.

## Install the NKP CLI

On the bootstrap node, extract the bundle and install the CLI:

```bash
tar -xzvf nkp-bundle_v2.18.0_linux_amd64.tar.gz
sudo install -m 0755 ./nkp-v2.18.0/cli/nkp /usr/local/bin/nkp
nkp version
```

Load the bootstrap image:

```bash
docker load --input nkp-v2.18.0/konvoy-bootstrap-image-v2.18.0.tar
```

## Configure the environment

Replace every example value:

```bash
export CLUSTER_NAME=nkp-mgmt-cluster
export MANAGEMENT_KUBECONFIG="$HOME/${CLUSTER_NAME}.conf"

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
```

Read the Prism Central password without storing it in shell history:

```bash
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

!!! warning "Lab-only TLS options"
    `--insecure` and `--skip-preflight-checks=Registry` are appropriate only when
    the lab uses untrusted certificates. Configure trusted certificate
    authorities and remove these options in production.

## Monitor provisioning

While the management cluster is created:

```bash
kind get kubeconfig --name konvoy-capi-bootstrapper > bootstrap-cluster.conf
kubectl --kubeconfig bootstrap-cluster.conf get clusters,machines -A
kubectl --kubeconfig bootstrap-cluster.conf get nutanixmachines -A
```

Do not remove the temporary kind cluster before the pivot completes.

## Verify the management cluster

```bash
kubectl --kubeconfig "${MANAGEMENT_KUBECONFIG}" get nodes
nkp get dashboard --kubeconfig "${MANAGEMENT_KUBECONFIG}"
```

Log in to the NKP UI and apply the required license.

## Next step

[Create a workspace](workspace.md) for the first workload cluster.
