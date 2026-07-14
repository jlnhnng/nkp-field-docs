# Installation guides

Choose the guide that matches the NKP version and deployment type.

## Prepare the bootstrap node

All management-cluster installations require a bootstrap node. You can prepare
one manually or create it with the included
[OpenTofu module](bootstrap-node/index.md).

## Standard

Use the standard path for a connected or registry-mirrored environment:

1. Create the management cluster.
2. Create a workspace.
3. Create or attach a workload cluster.
4. Create a project for application teams.

## Air-gapped

Use the air-gapped guide when cluster nodes cannot access public registries,
package repositories, or other internet services.

## Flow CNI

Use the Flow CNI guide when the cluster requires Nutanix Flow CNI
(OVN-Kubernetes) instead of the default Cilium CNI.

!!! tip
    Start with the newest NKP version unless you operate an existing older
    environment. Commands, Kubernetes versions, node images, and known issues can
    differ between releases.

## Conventions

- Uppercase environment variables represent values that differ by environment.
- Example IP addresses and DNS names must be replaced.
- `kubectl` commands target the management-cluster kubeconfig unless stated
  otherwise.
- `--insecure` examples are for labs. Use trusted certificates in production.
- Practical observations are marked as **Field note**.

!!! warning "Protect credentials"
    Do not store Prism Central, registry, or Git credentials in this repository
    or shell history. Use interactive prompts or an approved secret-management
    process.
