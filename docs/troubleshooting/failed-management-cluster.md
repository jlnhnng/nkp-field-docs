# Clean up a failed management-cluster installation

An NKP management-cluster installation can fail after Nutanix VMs and Cluster
API resources have already been created. If the failure cannot be corrected, use
the NKP CLI to remove the cluster declaratively.

Do not start by deleting the VMs in Prism Central. Cluster API must remove the
infrastructure it owns and complete its finalizers.

!!! danger "This procedure deletes the cluster"
    Use this procedure only when the management cluster is disposable and must be
    rebuilt. It removes control plane and worker nodes and can remove Kubernetes
    resources such as `LoadBalancer` Services. It is not a repair command.

## Collect evidence first

Before deleting anything:

- preserve the installer output and generated manifests;
- record the NKP CLI version and exact creation command;
- preserve the management and temporary bootstrap kubeconfigs;
- collect a [support bundle](support-bundle.md) with `nkp diagnose` while the
  management or bootstrap API is still reachable;
- record Cluster API conditions, events, and failed controller logs.

```bash
nkp version

kubectl --kubeconfig /path/to/management.conf get clusters,machines -A
kubectl --kubeconfig /path/to/management.conf get \
  nutanixclusters,nutanixmachines -A
```

These commands also show the namespace containing the `Cluster` resource. Do
not assume that it is `default`.

## Determine where Cluster API is running

Management-cluster creation starts with a temporary kind cluster. NKP later
pivots the Cluster API resources into the new management cluster.

The correct cleanup path depends on whether that pivot completed:

- **After the pivot:** the new management cluster contains its own `Cluster`
  resource. Delete it as a self-managed cluster.
- **Before the pivot:** the temporary `konvoy-capi-bootstrapper` kind cluster
  still owns the resources. Use that bootstrap cluster for investigation and
  cleanup.

Check the management cluster first:

```bash
kubectl --kubeconfig /path/to/management.conf get clusters -A
```

If the expected resource is not present, inspect the temporary bootstrap
cluster:

```bash
kind get clusters
kind get kubeconfig \
  --name konvoy-capi-bootstrapper > bootstrap-cluster.conf

kubectl --kubeconfig bootstrap-cluster.conf get clusters,machines -A
```

Keep the bootstrap node and kind cluster until cleanup or troubleshooting is
complete.

## Delete after a completed pivot

Use an NKP CLI version appropriate for the installed release. Run the command
from a bootstrap host with Docker and access to the management-cluster API,
Prism Central, and required container images.

```bash
export CLUSTER_NAME="nkp-mgmt"
export CLUSTER_NAMESPACE="default"
export MANAGEMENT_KUBECONFIG="/home/nutanix/nkp-mgmt-cluster.conf"

nkp delete cluster \
  --cluster-name="${CLUSTER_NAME}" \
  --namespace="${CLUSTER_NAMESPACE}" \
  --kubeconfig="${MANAGEMENT_KUBECONFIG}" \
  --self-managed \
  --timeout=30m
```

Replace `CLUSTER_NAMESPACE` with the namespace reported by `kubectl get
clusters -A`.

The `--self-managed` flag is important. A management cluster hosts the Cluster
API controllers and resources that describe itself, so it cannot simply remove
its own control plane. The NKP CLI creates a temporary bootstrap cluster, moves
the required lifecycle resources to it, deletes the target cluster, and then
removes the temporary cluster.

The kubeconfig must belong to the self-managed management cluster being deleted.
It is not a workload-cluster kubeconfig.

!!! note "Restricted and air-gapped environments"
    The delete operation needs the release-compatible bootstrap image. Confirm
    the image shown by `nkp delete cluster --help` is available from the
    bootstrap host or internal registry. Use the release-specific
    `--bootstrap-cluster-image` option when required.

## Delete before the pivot

When the temporary kind cluster still owns the target `Cluster` resource, it is
acting as the management cluster for that incomplete installation. Point the
delete command at its kubeconfig and omit `--self-managed`:

```bash
export CLUSTER_NAME="nkp-mgmt"
export CLUSTER_NAMESPACE="default"

nkp delete cluster \
  --cluster-name="${CLUSTER_NAME}" \
  --namespace="${CLUSTER_NAMESPACE}" \
  --kubeconfig=bootstrap-cluster.conf \
  --timeout=30m
```

Confirm the cluster name and namespace from the bootstrap cluster before running
the command. Do not use this path merely because the target cluster is
unhealthy; use it only when the Cluster API resources have not been pivoted.

## If deletion stalls

Inspect the owning management or bootstrap cluster:

```bash
export KUBECONFIG_PATH="/path/to/management-or-bootstrap.conf"

kubectl --kubeconfig "${KUBECONFIG_PATH}" get \
  clusters,machines,nutanixclusters,nutanixmachines -A

kubectl --kubeconfig "${KUBECONFIG_PATH}" get events \
  -n "${CLUSTER_NAMESPACE}" \
  --sort-by=.lastTimestamp
```

Common causes include:

- Prism Central or Prism Element connectivity failures;
- expired or invalid infrastructure credentials;
- unavailable CAPI or CAPX controllers;
- unreachable container registries or bootstrap images;
- Kubernetes resources with cleanup operations that cannot complete;
- manually deleted Nutanix resources that no longer match CAPI state.

Fix the underlying dependency and retry the same NKP deletion command.

!!! warning "Do not remove finalizers as a first response"
    A finalizer records cleanup that a controller still needs to perform.
    Removing it manually can leave VMs, disks, addresses, or load balancer
    resources behind. Do so only through a release-specific support procedure.

If neither the management API nor the owning temporary bootstrap cluster is
available, restore access or contact Nutanix support before manually deleting
infrastructure.

## Verify cleanup

After the command completes:

1. Confirm the cluster VMs and attached resources are gone in Prism Central.
2. Check for manually managed DNS records, certificates, IP reservations, and
   registry content.
3. Verify that no temporary bootstrap cluster remains with `kind get clusters`.
4. Preserve diagnostics, then securely remove obsolete kubeconfigs and local
   credential files.

NKP can delete resources it manages. External resources created outside the
Cluster API workflow require separate cleanup.
