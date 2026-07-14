# Create an air-gapped workload cluster

> Tested with NKP 2.17.1

Use the same Nutanix infrastructure values and sizing as the
[standard workload-cluster guide](../standard/workload-cluster.md), but use the
offline-capable NKP 2.17.1 node image and image-distribution method prepared for
the air-gapped management cluster.

## Configure air-gapped values

```bash
export MANAGEMENT_KUBECONFIG="$HOME/nkp-mgmt-cluster.conf"
export WORKSPACE_NAME=dev-workspace
export CLUSTER_NAME=nkp-dev-cluster
export NUTANIX_MACHINE_TEMPLATE_IMAGE_NAME=nkp-ubuntu-24.04-1.34.3-YYYYMMDDHHMMSS
```

Generate the command from the standard guide and add:

```bash
--namespace "${WORKSPACE_NAME}" \
--bundle=./container-images/*.tar \
--airgapped \
--kubeconfig "${MANAGEMENT_KUBECONFIG}"
```

For an external registry, replace `--bundle` with the same
`--registry-mirror-*` and `--registry-*` options used by the management cluster.

## Verify

```bash
kubectl --kubeconfig "${MANAGEMENT_KUBECONFIG}" \
  get clusters,machines -n "${WORKSPACE_NAME}"
kubectl --kubeconfig "${CLUSTER_NAME}.conf" get nodes
kubectl --kubeconfig "${CLUSTER_NAME}.conf" get pods -A
```

Verify that the cluster remains healthy with public registry access blocked.

## Next step

[Create a project](project.md).
