# Frequently asked questions

## Does the bootstrap node have to run Ubuntu?

No. The bootstrap node is an execution host for the NKP CLI, Docker, and a
temporary kind cluster. It can be a compatible Linux machine, Linux VM, or
macOS workstation. Ubuntu is used by the included
[OpenTofu example](../install/bootstrap-node/index.md).

Match the NKP CLI and container images to the host operating system and CPU
architecture. Check release support before using an ARM or Apple Silicon host.

## What is the difference between Konvoy and Kommander?

**Konvoy** is the historical name associated with Kubernetes cluster creation,
node images, runtime, and lifecycle operations.

**Kommander** is the multi-cluster management layer. It provides workspaces,
projects, platform applications, fleet views, and the management UI.

Both names remain in current commands, images, namespaces, and logs. See
[Structure and history](../index.md#structure-and-history).

## Why do current NKP resources use `mesosphere.io` or `d2iq.io`?

Kubernetes API-group names are stable identifiers. Renaming them when the company
or product name changes would require disruptive API and data migrations.
Legacy-looking domains can therefore identify current, supported resources.

Do not change an `apiVersion` merely to make it use a Nutanix domain.

## Should application workloads run on the management cluster?

Normally, no. The management cluster should be reserved for NKP controllers,
fleet services, and platform administration. Run business applications on
managed or attached workload clusters.

## Can one management cluster manage multiple Prism Element clusters?

Yes. A management cluster can manage workload clusters on multiple Prism Element
clusters. Multi-Prism Central and mixed-provider designs depend on the NKP
edition and release.

NKP can also use supported Prism Element failure domains to distribute one
cluster's nodes. Validate networking, storage topology, latency, licensing, and
the compatibility matrix before implementing that pattern.

See [Availability and recovery](../architecture/availability-and-recovery.md).

## What happens when the management cluster is unavailable?

Existing workload clusters and applications continue running. Central lifecycle
and fleet operations are affected, including cluster creation, scaling, upgrades,
the Kommander UI, and centralized authentication or reconciliation services.

Keep protected administrative kubeconfigs and a tested management-plane recovery
procedure.

## What is the difference between standard, air-gapped, and Flow CNI installs?

- **Standard** uses the normal connected or registry-mirrored workflow.
- **Air-gapped** transfers all required bundles, node images, packages, and
  registry content into a disconnected environment.
- **Flow CNI** replaces the default Cilium network implementation with Nutanix
  Flow CNI and requires a modified cluster manifest.

Choose the path before cluster creation. Retrofitting a different CNI into a
running cluster is disruptive.

## Does an air-gapped installation require an external registry?

Not always. NKP supports a built-in infrastructure registry workflow as well as
an external enterprise registry. An external registry is useful when an
organization already operates Harbor, Artifactory, Nexus, or another supported
registry as a shared service.

See [Air-gapped deployment](../architecture/air-gapped.md).

## Why is a cluster stuck while its VMs appear healthy?

VM power state is only one part of Cluster API reconciliation. Start with the
Kubernetes conditions and events:

```bash
kubectl get clusters,machines -A
kubectl get kubeadmcontrolplanes,machinedeployments -A
kubectl describe cluster <cluster-name> -n <namespace>
kubectl get events -n <namespace> --sort-by=.lastTimestamp
```

Then inspect `NutanixCluster`, `NutanixMachine`, and controller logs. The first
failed condition usually identifies whether the problem is infrastructure,
bootstrap, networking, or control plane readiness.

## Which namespace contains the management cluster?

Discover it instead of assuming:

```bash
kubectl get clusters -A
```

Management clusters upgraded from NKP 2.17 commonly retain the `default`
namespace. Newer deployments can use `kommander`. Use the namespace reported by
the resource in CLI commands.

## Can I skip an intermediate NKP release during an upgrade?

Do not skip a release unless the supported upgrade matrix explicitly permits it.
For the paths documented here, complete `2.17.0 → 2.17.1` before
`2.17.1 → 2.18.0`.

Upgrade the management plane and verify it before upgrading managed workload
clusters.

## Which NKP CLI version should I use?

Use the CLI required by the operation and target release. During an upgrade,
retain the previous CLI until every dependent environment has reached the target
version.

Always verify before running a lifecycle command:

```bash
nkp version
```

## What should I collect before asking for support?

Record:

- NKP CLI and cluster versions;
- affected cluster name and namespace;
- when the issue started and the last known change;
- relevant Cluster API conditions and events;
- whether the environment is connected, restricted, or air-gapped;
- a support bundle from the affected management or workload cluster.

Follow the [Support bundle](support-bundle.md) guide.
