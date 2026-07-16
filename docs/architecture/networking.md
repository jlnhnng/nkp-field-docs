# Networking

NKP uses the Kubernetes Container Network Interface (CNI) model. The CNI provides
pod connectivity and enforces Kubernetes network policy.

## CNI options

=== "Cilium (default)"

    NKP ships **[Cilium](https://cilium.io/)** as the default CNI. Cilium uses
    **eBPF** in the Linux kernel to provide high-performance networking, load
    balancing, and network policy without relying on iptables.

    - eBPF-based dataplane (low overhead, high throughput)
    - Kubernetes `NetworkPolicy` **and** richer `CiliumNetworkPolicy`
    - Identity-based security, L3–L7 policy
    - Hubble for network observability

    No special flags are required — a standard `nkp create cluster` installs Cilium
    automatically.

=== "Nutanix Flow CNI (OVN-Kubernetes)"

    For AHV environments that want **hypervisor-level microsegmentation**, NKP
    supports **Nutanix Flow CNI**, built on
    **[OVN-Kubernetes](https://github.com/ovn-org/ovn-kubernetes)**. Flow CNI
    enforces Kubernetes network policy at the AHV layer, offloading it from the
    guest.

    Flow CNI must be selected when you create the cluster. See
    [Install NKP with Flow CNI](../install/v2.18/flow-cni/management-cluster.md) for the
    field procedure.

## Choosing a CNI

| Consideration | Cilium | Flow CNI (OVN-Kubernetes) |
| --- | --- | --- |
| Default / simplest install | ✅ | Requires manifest editing |
| Dataplane | eBPF (in-guest) | OVN + AHV integration |
| Policy enforcement point | Node kernel | AHV hypervisor |
| L7 policy / observability | ✅ (Hubble) | Limited |
| Best fit | Most clusters | AHV microsegmentation requirements |

!!! warning "Pick one at creation time"
    The CNI is chosen when the cluster is created. Switching CNIs on a running
    cluster is disruptive and generally requires a rebuild.

## Service and control plane addresses

On Nutanix AHV, reserve an address for the Kubernetes control plane endpoint and
an address range for services of type `LoadBalancer`. You provide the service
range during cluster creation:

```bash
export LB_IP_RANGE=10.54.61.12-10.54.61.12
```

The control plane address and service range must not be handed out by DHCP or used
by another system.

These stable endpoints are different from node addresses. CAPX-created Nutanix
VMs normally receive node addresses from Nutanix IPAM or DHCP. CAPI can then
replace a node without preserving the old VM's address.

## Worker VLANs

Kubernetes does not require every worker to be in one Layer 2 broadcast domain.
Nodes can use routed subnets when the CNI and all cluster dependencies have the
required connectivity. This does not mean that assigning a VLAN to each
application team is a useful Kubernetes multi-tenancy design.

A VLAN follows the worker VM. A Kubernetes namespace and its pods do not:

- the scheduler can place a pod on any eligible node;
- a replacement pod can start on a different node;
- a node pool can scale or be replaced through Cluster API;
- Services route traffic independently of the physical worker subnet.

With NKP's default Cilium configuration, traffic between nodes is normally
encapsulated. An underlay firewall then sees traffic between node addresses
rather than Kubernetes namespace or pod identity. Blocking that tunnel traffic
can break pod connectivity instead of isolating one tenant.

Use Kubernetes `NetworkPolicy` for application-level traffic rules. Use
namespaces, RBAC, quotas, and workload policy together for shared-cluster
[multi-tenancy](multi-tenancy.md). When a tenant requires a physical network
boundary, a dedicated workload cluster is usually clearer than dividing the
workers of one cluster into tenant VLANs.

### When separate worker subnets can make sense

Separate subnets can be valid when they represent an infrastructure requirement,
for example:

- a node pool with specialized hardware or network access;
- a controlled ingress, egress, or DMZ role;
- placement across routed infrastructure or failure domains;
- a validated requirement for dedicated tenant nodes.

NKP allows a subnet to be selected when a Nutanix worker node pool is created.
For example, `nkp create nodepool nutanix` exposes the `--subnets` option. This
assigns networking to the node pool; it does not associate a subnet with an NKP
project or Kubernetes namespace.

If only selected workloads may use that pool, combine node labels with taints,
tolerations, and node affinity. Network policy is still required because
scheduling controls do not filter traffic.

!!! warning "Validate multi-subnet clusters before production"
    Support and networking behavior depend on the NKP release, CNI, generated
    Cilium configuration, and Nutanix network design. Flow CNI has a different
    dataplane and must be validated separately. The presence of `--subnets` in
    the CLI does not prove that every VLAN and firewall topology is supported.

Before placing workers on different routed VLANs, verify:

- bidirectional node-to-node and node-to-control-plane reachability;
- every required Kubernetes and CNI port;
- VXLAN connectivity and MTU when the generated Cilium configuration uses
  tunnel mode;
- access to DNS, NTP, registries, Prism Central, storage, ingress, and load
  balancer addresses;
- non-overlapping node, pod, service, and load balancer address ranges;
- sufficient IPAM capacity for rolling upgrades and replacement nodes;
- pod rescheduling, node replacement, scaling, and upgrades across the boundary.

## Ingress and certificates

- **[Traefik](https://traefik.io/)** is the default ingress controller, exposing
  the NKP UI and workload HTTP(S) routes.
- **[cert-manager](https://cert-manager.io/)** automates TLS certificate issuance
  and rotation for platform endpoints.

## Pod and service CIDRs

Pod and service networks are configurable and must not overlap with each other or
the node subnet:

```bash
export POD_CIDR=172.20.0.0
export SERVICE_CIDR=172.21.0.0
# passed as /16 to NKP; Flow CNI carves /24 blocks within it
```

!!! tip "Field note: document all address pools"
    Record node subnets, pod CIDRs, service CIDRs, control plane addresses, and
    load balancer ranges before installation. Overlap is difficult to correct
    after a cluster has been created.
