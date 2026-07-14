# NKP field docs

Practical documentation for platform engineers who build and operate the
**Nutanix Kubernetes Platform (NKP)**.

These field docs explain the architecture in plain language and record procedures
and lessons learned from real installations. They are not a replacement for
Nutanix support, release notes, or the compatibility matrix.

!!! info "How to use these docs"
    Use the architecture section to understand how NKP works. Use the
    version-specific installation guides when you are ready to build a cluster.
    Foundations are optional learning paths for readers who want shared context.
    Practical observations are marked as **Field note**.

<div class="grid cards" markdown>

-   :material-sitemap:{ .lg .middle } **Architecture**

    ---

    Understand the management plane, cluster types, and open source components.

    [:octicons-arrow-right-24: Architecture overview](architecture/index.md)

-   :material-kubernetes:{ .lg .middle } **Installation**

    ---

    Follow field-tested procedures for standard and custom deployments.

    [:octicons-arrow-right-24: Choose an installation guide](install/index.md)

-   :material-creation:{ .lg .middle } **AI inference**

    ---

    Explore the technical architecture for gateways, runtimes, GPUs, and storage.

    [:octicons-arrow-right-24: AI inference on NKP](architecture/ai-inference.md)

-   :material-compass-outline:{ .lg .middle } **Foundations**

    ---

    Optional learning paths for cloud native, Kubernetes, and AI fundamentals.

    [:octicons-arrow-right-24: Browse foundations](start-here/index.md)

</div>

## Built on open source

NKP uses upstream Kubernetes APIs and established open source projects for
cluster lifecycle, networking, storage, GitOps, and observability. NKP adds tested
integration, lifecycle management, security configuration, and support.

See [Open source components](architecture/open-source-primitives.md) for the
component map and links to the canonical upstream projects.

## Structure and history

NKP contains names from several generations of the platform. They remain visible
in CRDs, namespaces, container images, commands, and logs because Kubernetes API
groups and internal component names cannot be renamed without a migration.

### From Mesosphere to NKP

- **Mesosphere** originally developed datacenter orchestration technology and
  later introduced the Konvoy and Kommander Kubernetes products.
- Mesosphere became **D2iQ** in 2019. Konvoy and Kommander were brought together
  as the **D2iQ Kubernetes Platform (DKP)**.
- Nutanix acquired D2iQ technology and resources in 2023. DKP then evolved into
  the **Nutanix Kubernetes Platform (NKP)**, alongside capabilities from the
  Nutanix Kubernetes Engine.

This lineage explains why a current NKP cluster can contain API groups ending in
`mesosphere.io`, `d2iq.io`, and `nutanix.com`.

### Names you still encounter

**Konvoy** is the historical name associated with Kubernetes cluster creation,
the Kubernetes runtime, node images, and lifecycle operations. It can still
appear in bundle names, images, and internal resources.

**Kommander** is the multi-cluster management layer. It provides workspaces,
projects, platform applications, fleet visibility, and the management UI. Names
such as `kommander`, `kommander-workspace`, and
`workspaces.kommander.mesosphere.io` are therefore still current operational
identifiers.

### Read API domains as ownership history

The domain in an `apiVersion` identifies the API group, not necessarily the
current product brand:

- `*.mesosphere.io` usually identifies APIs created during the Mesosphere and
  early Kommander/Konvoy period.
- `*.d2iq.io` identifies components introduced during the D2iQ period.
- `*.nutanix.com`, including `caren.nutanix.com`, identifies newer Nutanix
  components and runtime extensions.
- `*.cluster.x-k8s.io` belongs to upstream Cluster API. Nutanix infrastructure
  resources such as `NutanixCluster` and `NutanixMachine` use its infrastructure
  API group.
- Domains such as `*.toolkit.fluxcd.io` and `*.k8s.io` belong to their respective
  upstream projects.

!!! warning "Do not rename legacy API groups"
    A legacy-looking domain does not mean that a resource is obsolete. Use the
    API version shipped with the installed NKP release, and do not rewrite
    manifests merely to make the domain match current Nutanix branding.

Further context is available from
[D2iQ joins Nutanix](https://www.nutanix.com/d2iq).
