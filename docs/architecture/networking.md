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
