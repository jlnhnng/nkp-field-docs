# Create an air-gapped workload cluster

> Tested with NKP 2.19.0

The workload cluster must use the same internal image-distribution design as the
management cluster.

## Before you begin

You need a healthy air-gapped management cluster, a workspace, the supported
offline node image, reserved IP addresses, and either accessible bundle files or
an internal registry containing all NKP images.

!!! warning "Check before you start (NKP 2.19)"
    - Kubernetes 1.36.2 is the default version. The matching node image is
      Rocky Linux 9.8. Use the image name exactly as it appears in Prism Central.
    - With Prism Central Projects 2.0, a cluster uses **one** Prism Central
      project for all its resources, such as VMs and volume groups. To use a
      user-defined project, add `--pc-project=<project-name>`. Omit the flag for
      the default project (`_internal`). The older `--control-plane-pc-project`
      and `--worker-pc-project` flags are deprecated. Prism Central, Prism
      Element, and AOS must be 7.6 or later for a user-defined project. The
      project cannot be changed after creation.

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
export NUTANIX_MACHINE_TEMPLATE_IMAGE_NAME=nkp-ubuntu-24.04-1.36.2-YYYYMMDDHHMMSS

export CONTROL_PLANE_ENDPOINT_IP=192.0.2.30
export LB_IP_RANGE=192.0.2.31-192.0.2.40

read -r -s -p "Prism Central password: " NUTANIX_PASSWORD
export NUTANIX_PASSWORD
echo
```

## Create the cluster with bundles

Run this command where the air-gapped bundle files are available:

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
  --control-plane-replicas 3 \
  --worker-replicas 3 \
  --bundle=./container-images/*.tar \
  --airgapped \
  --kubeconfig "${MANAGEMENT_KUBECONFIG}"
```

For an external registry, replace `--bundle` with the applicable
`--registry-mirror-*` and `--registry-*` options used for the management
cluster.

## Verify the cluster

```bash
kubectl --kubeconfig "${MANAGEMENT_KUBECONFIG}" \
  get clusters,machines -n "${WORKSPACE_NAME}"
kubectl --kubeconfig "${CLUSTER_NAME}.conf" get nodes
kubectl --kubeconfig "${CLUSTER_NAME}.conf" get pods -A
```

Resolve every image-pull failure and verify that DNS, NTP, storage, and internal
endpoints work without public network access.

## Next step

[Create a project](project.md).
