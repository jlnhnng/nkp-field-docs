# Open source components

This reference maps NKP capabilities to their main upstream projects. NKP
integrates, tests, secures, and supports these components as a platform.

!!! note "Versions vary by release"
    This is a conceptual map, not a compatibility matrix. Use the NKP
    release-specific compatibility information when you need an exact component
    version.

## Kubernetes and cluster lifecycle

| Capability | Upstream project | NKP integration |
| --- | --- | --- |
| Kubernetes API and control plane | [Kubernetes](https://kubernetes.io/) | Tested Kubernetes distribution and upgrades |
| Cluster lifecycle | [Cluster API](https://cluster-api.sigs.k8s.io/) | Declarative creation, scaling, and upgrades |
| Nutanix infrastructure | [CAPX](https://github.com/nutanix-cloud-native/cluster-api-provider-nutanix) | Prism Central and AHV reconciliation |
| Node images | [Kubernetes Image Builder](https://image-builder.sigs.k8s.io/) | Supported operating system images |
| Temporary bootstrap | [kind](https://kind.sigs.k8s.io/) | Automated bootstrap and pivot |
| Container runtime | [containerd](https://containerd.io/) | Supported runtime configuration |

## Cluster services

| Capability | Upstream project or standard | NKP integration |
| --- | --- | --- |
| Default container networking | [Cilium](https://cilium.io/) and CNI | Tested cluster network and policy |
| Nutanix Flow networking | [OVN-Kubernetes](https://ovn-kubernetes.io/) and CNI | Integration with Nutanix Flow |
| Persistent storage | [CSI](https://kubernetes-csi.github.io/docs/) and [Nutanix CSI](https://github.com/nutanix/csi-plugin) | Dynamic storage provisioning |
| Image format and distribution | [OCI specifications](https://opencontainers.org/) | Standard container image workflows |
| Infrastructure registry | [CNCF Distribution](https://distribution.github.io/distribution/) | Registry used by air-gapped workflows |

## Application operations

| Capability | Upstream project | NKP integration |
| --- | --- | --- |
| GitOps reconciliation | [Flux](https://fluxcd.io/) | Multi-cluster application delivery |
| Application packaging | [Helm](https://helm.sh/) | Tested platform and catalog applications |
| Metrics | [Prometheus](https://prometheus.io/) | Platform monitoring application |
| Dashboards | [Grafana](https://grafana.com/oss/grafana/) | Cluster and fleet views |
| Log collection | [Fluent Bit](https://fluentbit.io/) | Platform logging pipeline |
| Backup and restore | [Velero](https://velero.io/) | Kubernetes resource and volume backup workflows |

## Optional AI building blocks

These projects can be deployed on NKP but should not be assumed to be part of the
default platform:

| Capability | Upstream project |
| --- | --- |
| AI endpoint and traffic management | [Envoy AI Gateway](https://aigateway.envoyproxy.io/) |
| Model serving runtime | [vLLM](https://docs.vllm.ai/) |
| Shared inference cache | [LMCache](https://docs.lmcache.ai/) |

See [AI inference on NKP](ai-inference.md) for the architecture and the distinction
between an open source stack and Nutanix Enterprise AI.

## What remains portable

Using upstream APIs does not make every infrastructure detail portable, but it
reduces platform-specific surface area:

- Kubernetes manifests and Helm charts use familiar formats.
- Cluster lifecycle is represented by Cluster API resources.
- GitOps state is represented by Flux resources.
- Storage and networking use standard Kubernetes interfaces.
- Operators can inspect the platform with `kubectl` and upstream tools.

## Canonical upstream documentation

Follow the linked upstream documentation for project-specific APIs and behavior.
These field docs focus on how the components fit together in NKP and on practical
operational lessons.
