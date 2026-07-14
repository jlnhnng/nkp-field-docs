# Deployment models

NKP can operate in connected, restricted, and fully air-gapped environments. The
cluster architecture remains similar; the main difference is how installation
artifacts, container images, operating system packages, and application catalogs
reach the clusters.

## Choose a model

| Model | External access | Image source | Typical use |
| --- | --- | --- | --- |
| **Connected** | Bootstrap host and clusters can reach required services | Public registries, optionally through a mirror | Development and environments with controlled internet access |
| **Restricted** | Access is limited by proxies or allowlists | Enterprise registry or proxy cache | Enterprise production environments |
| **Air-gapped** | No external access from the target environment | NKP bundle and internal registry | Dark sites and isolated regulated environments |

Restricted environments are often described as air-gapped even when selected
external endpoints remain reachable. Document the actual network paths instead
of relying only on the label.

## Architecture shared by all models

Every model uses the same main roles:

1. A bootstrap host runs the `nkp` CLI and creates the initial management cluster.
2. The management cluster hosts fleet-management and lifecycle controllers.
3. Managed workload clusters are created from the management cluster.
4. Attached clusters can be connected without transferring infrastructure
   lifecycle ownership to NKP.

See [Clusters](clusters.md) and [Cluster lifecycle](cluster-lifecycle.md) for
details.

## Decisions to make before installation

- Which systems may access the internet?
- Will clusters pull directly, through a proxy cache, or from a private registry?
- How will NKP bundles and node images enter the environment?
- Which certificate authority signs internal endpoints?
- Which DNS, NTP, identity, and storage services must be reachable?
- How will updated images and catalogs be synchronized after installation?

!!! tip "Field note: draw the artifact path"
    Draw the path from the downloaded NKP bundle to the bootstrap host,
    management cluster, and workload clusters. Include registry endpoints,
    certificates, proxies, and firewall boundaries. Most deployment differences
    become clear in this one diagram.

## Continue

- [Connected deployment](connected-deployment.md)
- [Air-gapped deployment](air-gapped.md)
- [Standard NKP 2.18 installation](../install/v2.18/standard/management-cluster.md)
