# Create a support bundle

The NKP CLI generates diagnostic archives with `nkp diagnose`. A bundle can
include Kubernetes resources, pod logs, cluster information, and node-level
diagnostics.

> Commands on this page were checked with the NKP 2.17.1 CLI. Run
> `nkp diagnose --help` with the CLI matching your environment because flags and
> collectors can change between releases.

## Before you begin

You need:

- the NKP CLI matching the environment;
- a working kubeconfig for the affected cluster;
- sufficient permissions to read cluster resources, logs, and secrets and to run
  the diagnostic node collector;
- enough local disk space for the resulting archive;
- access to the diagnostic collector images.

The default node collector runs a privileged pod with host access. Follow your
organization's change and security process before collecting diagnostics.

!!! danger "Support bundles contain sensitive data"
    A bundle can contain logs, Kubernetes resources, Secrets, certificates,
    endpoint names, IP addresses, and infrastructure details. Store it securely,
    inspect it before sharing, and upload it only through an approved support
    channel.

## Check the CLI and access

```bash
nkp version
nkp diagnose --help
kubectl --kubeconfig <path-to-kubeconfig> cluster-info
kubectl --kubeconfig <path-to-kubeconfig> get nodes
```

Use an administrative identity or an approved diagnostic role. By default, the
CLI can still produce a partial bundle when some collectors lack permission.
Record permission failures because the missing data can affect troubleshooting.

## Collect from the management cluster

Create a dedicated local directory:

```bash
mkdir -p "$HOME/nkp-support"
cd "$HOME/nkp-support"
```

Collect the last 24 hours:

```bash
export MANAGEMENT_KUBECONFIG="$HOME/nkp-mgmt-cluster.conf"

nkp diagnose \
  --kubeconfig "${MANAGEMENT_KUBECONFIG}" \
  --since 24h \
  --bundle-name-prefix "management-$(date -u +%Y%m%dT%H%M%SZ)-"
```

The CLI writes the compressed support bundle to the current directory and
reports its filename.

Use `--since-time` instead of `--since` when the incident has a known UTC start
time:

```bash
nkp diagnose \
  --kubeconfig "${MANAGEMENT_KUBECONFIG}" \
  --since-time "2026-07-14T07:00:00Z" \
  --bundle-name-prefix "management-incident-"
```

## Collect from a workload cluster

Use the affected workload cluster's kubeconfig:

```bash
export WORKLOAD_KUBECONFIG="$HOME/nkp-dev-cluster.conf"

nkp diagnose \
  --kubeconfig "${WORKLOAD_KUBECONFIG}" \
  --since 24h \
  --bundle-name-prefix "nkp-dev-cluster-"
```

For lifecycle or fleet-management incidents, collect a management-cluster bundle
as well as a bundle from the affected workload cluster.

## Include the temporary bootstrap cluster

During management-cluster provisioning, collect data from both the target and
temporary kind cluster when they are reachable:

```bash
kind get kubeconfig --name konvoy-capi-bootstrapper > bootstrap-cluster.conf

nkp diagnose \
  --kubeconfig "$HOME/nkp-mgmt-cluster.conf" \
  --bootstrap-kubeconfig bootstrap-cluster.conf \
  --since 4h \
  --bundle-name-prefix "management-bootstrap-"
```

If the target management-cluster API is not yet available, preserve the
bootstrap kubeconfig and collect the Cluster API resources, controller logs, and
events directly before deleting the kind cluster.

## Inspect the configured collectors

Display the default support-bundle specification:

```bash
nkp diagnose default-config
```

The default specification shows the exact images and collectors used by that CLI
version. It commonly includes cluster resources, all namespace logs, Secrets,
and privileged node diagnostics.

This command is especially useful in restricted environments: mirror every
referenced collector and pause image before running `nkp diagnose`.

## Optional SSH node diagnostics

The CLI can collect directly from nodes over SSH:

```bash
nkp diagnose ssh path/to/inventory-file.yaml \
  --bundle-name-prefix "node-diagnostics-" \
  --timeout 10m
```

Use this mode when Kubernetes-based node collectors cannot run or when Nutanix
support requests it. Protect the inventory file because it can contain node
addresses and access information. Check the inventory format required by the
installed release before use:

```bash
nkp diagnose ssh --help
```

## Review and transfer the archive

Identify and inspect the generated archive:

```bash
ls -lh *.tar.gz
tar -tzf <support-bundle>.tar.gz
shasum -a 256 <support-bundle>.tar.gz
```

Extract it only into a protected directory if content review is required. Do not
attach support bundles to public issues, chat rooms, or source repositories.

## Common collection failures

### Collector pods cannot pull images

Mirror the images shown by `nkp diagnose default-config` and confirm the
cluster's registry configuration. This is common in air-gapped environments.

### The bundle reports permission errors

Use an approved identity with broader diagnostic access, or share the partial
bundle together with the permission errors. Do not assume that a generated
archive is complete.

### Collection times out

Reduce the log window with `--since`, check unhealthy nodes and API connectivity,
or increase the per-node timeout for `nkp diagnose ssh`.

### TLS validation fails

Prefer a trusted certificate authority and the correct server name. Options that
disable certificate verification are intended only for controlled diagnostics
and expose the connection to interception.
