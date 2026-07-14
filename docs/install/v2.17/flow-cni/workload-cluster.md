# Create a workload cluster with Flow CNI

> Tested with NKP 2.17.1

Use the [NKP 2.18 Flow CNI workload procedure](../../v2.18/flow-cni/workload-cluster.md)
with these release-specific values:

```bash
export NKP_VERSION=2.17.1
export NUTANIX_MACHINE_TEMPLATE_IMAGE_NAME=nkp-ubuntu-24.04-release-cis-1.34.3.qcow2
export FLOW_CHART_VERSION=1.3.0
```

The required workflow is the same:

1. Generate the 2.17.1 workload-cluster manifest with the workspace namespace,
   management kubeconfig, pod CIDR, service CIDR, and `--dry-run -o yaml`.
2. Remove `.spec.topology.variables[0].value.addons.cni`.
3. Read `caren.nutanix.com/cluster-uuid`.
4. Add the Flow CNI `HelmChartProxy` in the workspace namespace.
5. Apply the complete manifest with server-side apply.

## Verify

```bash
export MANAGEMENT_KUBECONFIG="$HOME/nkp-mgmt-cluster.conf"
export WORKSPACE_NAME=dev-workspace
export CLUSTER_NAME=nkp-dev-cluster

kubectl --kubeconfig "${MANAGEMENT_KUBECONFIG}" \
  get helmchartproxy,clusters,machines -n "${WORKSPACE_NAME}"
kubectl --kubeconfig "${CLUSTER_NAME}.conf" get nodes
kubectl --kubeconfig "${CLUSTER_NAME}.conf" get pods -n flow-cni-system
```

!!! warning
    Use the NKP 2.17.1 CLI and node image. Do not substitute 2.18 artifacts.

## Next step

[Create a project](project.md).
