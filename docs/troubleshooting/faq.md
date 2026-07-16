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

## Do Kubernetes nodes need static IP addresses?

Normally, no. With `nkp create cluster nutanix`, CAPX creates and replaces node
VMs while Nutanix IPAM or DHCP assigns their addresses. The NKP CLI does not
expose flags for assigning a fixed address to each Nutanix node.

This is intentional. A `Machine` is replaceable infrastructure: when CAPI
repairs, scales, or upgrades a cluster, it can create a new VM with a new address
and remove the old one. Kubernetes Services, DNS, and the control plane endpoint
provide stable access above those changing nodes.

Do reserve static addresses for:

- the Kubernetes control plane endpoint;
- service `LoadBalancer` address ranges;
- ingress or other explicitly designed external endpoints.

Those addresses must be outside DHCP or Nutanix IPAM pools to prevent conflicts.

If an organization requires already-created hosts with fixed addresses,
`nkp create cluster preprovisioned` accepts an inventory of those hosts and
connects to them over SSH. This is not a static-IP option for CAPX-created AHV
VMs: the organization becomes responsible for provisioning, addressing, and
maintaining the host inventory.

The pre-provisioned provider still uses CAPI and supports NKP lifecycle
operations for Kubernetes, the control plane, and core add-ons. It does not
create, repair, or delete the underlying hosts. Scaling or replacing capacity
therefore requires suitable hosts to be added to the external inventory.

Use pre-provisioned infrastructure because the environment requires existing
hosts—not only to make replaceable nodes look like traditional permanent VMs.
See [From VMs to Kubernetes](../start-here/from-vms-to-kubernetes.md#stable-endpoints-replaceable-nodes).

## Should Kubernetes workers be placed in different VLANs?

Not by default. A routed multi-subnet cluster can work, but VLANs are normally
the wrong boundary for applications or NKP projects.

A VLAN is attached to a worker VM. Pods are scheduled and rescheduled across
eligible workers, so a namespace does not stay in one VLAN unless additional
scheduling rules dedicate nodes to it. Even then, taints and affinity control
placement—not network traffic.

For shared clusters, use:

- `NetworkPolicy` for pod and namespace traffic;
- RBAC for API access;
- quotas for shared capacity;
- workload policy for pod security;
- dedicated node pools only where hardware or capacity separation is required.

Use a dedicated workload cluster when a tenant needs a physical network or
stronger security boundary.

NKP can select a Nutanix subnet for a worker node pool with
`nkp create nodepool nutanix --subnets`. Use this for a validated infrastructure
requirement, not to recreate a VLAN-per-application VM design. All worker
subnets must provide the connectivity required by the selected CNI, Kubernetes
control plane, storage, registries, and platform services.

See [Worker VLANs](../architecture/networking.md#worker-vlans) for design and
validation guidance.

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
