# Glossary

Short definitions for terms used throughout these field docs.

AI gateway
:   A traffic and policy layer in front of model endpoints. It can provide
    routing, authentication, usage limits, failover, and AI-specific telemetry.

Air-gapped
:   An environment that cannot access external networks. Required artifacts must
    be transferred in and served from internal systems.

Attached cluster
:   A Kubernetes cluster created outside NKP and connected for supported
    management services. NKP does not own its infrastructure lifecycle.

CAPX
:   Cluster API Provider Nutanix. The controller that translates Cluster API
    resources into operations on Nutanix infrastructure.

Cilium
:   The default NKP Container Network Interface implementation. It uses eBPF for
    networking, service handling, and network policy.

Cloud native
:   An operating model based on APIs, declared state, automation, reconciliation,
    replaceable components, and observable systems. It does not mean only public
    cloud.

Cluster API (CAPI)
:   An upstream Kubernetes project that represents Kubernetes clusters and
    machines as declarative API resources.

CNI
:   Container Network Interface. A standard used to connect pods to the cluster
    network.

Container
:   An isolated application process packaged with its runtime dependencies. A
    container is not a complete virtual machine.

Container image
:   An immutable package used to create containers.

Controller
:   Software that watches desired and actual state and takes action to reconcile
    them.

CSI
:   Container Storage Interface. A standard that connects Kubernetes storage
    requests to storage systems.

D2iQ
:   The company name adopted by Mesosphere in 2019. Its D2iQ Kubernetes Platform
    technology later evolved into NKP after joining Nutanix.

Desired state
:   The declared configuration that controllers attempt to maintain.

Deployment
:   A Kubernetes workload controller commonly used for stateless replicated
    applications and rolling updates.

Envoy AI Gateway
:   An open source project built on Envoy Proxy and Kubernetes Gateway API for
    routing and governing generative AI traffic.

Flux
:   An open source GitOps toolkit that reconciles Kubernetes resources from
    declared sources such as Git, Helm, and OCI repositories.

GitOps
:   An operating practice in which version-controlled, declarative configuration
    is reconciled automatically into a running system.

GPU node
:   A Kubernetes node with GPU resources and the software required to advertise
    them to the scheduler.

Helm
:   A Kubernetes application packaging and release-management tool.

Inference
:   Using a trained model to generate a prediction, classification, embedding, or
    response.

Inference endpoint
:   A stable API through which applications send inference requests.

Inference runtime
:   Software that loads a model and serves inference requests, such as NVIDIA NIM
    or vLLM.

Kommander
:   The NKP multi-cluster management layer that runs on the management cluster.

Konvoy
:   The historical product and component name associated with Kubernetes cluster
    creation, runtime, node images, and lifecycle operations.

Kubeconfig
:   A file containing Kubernetes cluster connection, identity, and context
    information used by tools such as `kubectl`.

Kubernetes node
:   A physical or virtual machine that runs pods. On Nutanix AHV, NKP nodes are
    commonly virtual machines.

KV cache
:   Key-value attention data retained by an LLM runtime to avoid recomputing
    earlier tokens during generation.

Large language model (LLM)
:   A model trained to process and generate language represented as tokens.

Managed cluster
:   A workload cluster whose infrastructure lifecycle is controlled by NKP
    through Cluster API.

Management cluster
:   The NKP cluster that hosts fleet-management, application, and Cluster API
    controllers.

Mesosphere
:   The original company name behind technology that later became D2iQ and then
    formed part of NKP.

Mindthegap
:   An open source utility for creating and importing OCI image bundles in
    air-gapped environments.

Namespace
:   A Kubernetes scope for resource names, access control, quota, and policy
    inside one cluster.

NKP
:   Nutanix Kubernetes Platform.

Nutanix Enterprise AI (NAI)
:   A Nutanix product for deploying, managing, and governing AI models and
    inference endpoints on supported Kubernetes environments.

OCI
:   Open Container Initiative. It defines standards used for container image
    formats, runtimes, and distribution.

PersistentVolumeClaim (PVC)
:   A Kubernetes workload's request for persistent storage.

Pod
:   The smallest Kubernetes scheduling unit. It contains one or more containers
    that share networking and storage context.

Prism Central
:   The Nutanix management plane used by CAPX to provision and manage resources
    on Nutanix infrastructure.

Project
:   An NKP application-team boundary that provides a namespace and configuration
    scope across selected clusters in one workspace.

RAG
:   Retrieval-augmented generation. A pattern that retrieves relevant information
    and adds it to a model's context at inference time.

Reconciliation
:   The repeated process of comparing desired state with actual state and acting
    to reduce the difference.

Replica
:   One running instance of a workload managed as part of a desired count.

Service
:   A Kubernetes resource that gives a changing group of pods a stable network
    address and DNS name.

StorageClass
:   A Kubernetes resource that describes how a class of persistent storage is
    provisioned.

Token
:   A unit of text processed or generated by a language model. A token is not
    always a complete word.

Vector database
:   A system optimized to store embeddings and find vectors similar to a query.

Workspace
:   An NKP boundary that groups clusters, administration, access controls, and
    platform applications.

Workload cluster
:   A Kubernetes cluster intended primarily to run application workloads rather
    than NKP fleet-management services.
