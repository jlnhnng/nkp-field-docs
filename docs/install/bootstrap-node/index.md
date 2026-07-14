# Prepare a bootstrap node

The bootstrap node runs the NKP CLI, Docker, and the temporary kind cluster used
to create the management cluster. You can create the VM with the included
OpenTofu module or prepare it manually.

The bootstrap node is an execution host, not a special NKP appliance or
Kubernetes node. It can be:

- a Linux VM or physical Linux machine;
- an administrator's Linux workstation;
- a macOS workstation or MacBook;
- the Ubuntu 24.04 VM created by the included OpenTofu module.

Ubuntu is used in these examples because it is straightforward to automate on
Nutanix AHV. Other Linux distributions work when the required NKP CLI build,
container runtime, and tools are available.

## Before you begin

Whichever host you choose needs:

- Docker with support for Linux containers;
- `kubectl`, `yq`, Git, and `jq`;
- an NKP CLI binary matching the host operating system and CPU architecture;
- network access to Prism Central, Prism Element, cluster networks, required
  registries, and package sources.

Provide at least 4 CPU cores, 8 GiB memory, and 100 GiB available disk space.
Air-gapped bundle handling can require more disk space.

!!! warning "Check CPU architecture"
    Before using an Apple Silicon Mac or ARM Linux host, confirm that the NKP
    CLI and bootstrap container images for your NKP release support `arm64`.
    Otherwise, use an `x86_64` Linux VM. Container emulation can be slower and
    might not be supported for every release.

## Option 1: OpenTofu

The included module creates the VM and configures it with cloud-init. It uses
standard `.tf` files because OpenTofu uses the HCL file format.

This option requires OpenTofu 1.8 or later, access to Prism Central, an Ubuntu
24.04 cloud image, a suitable subnet, and an SSH public key.

Download and install OpenTofu from the
[OpenTofu installation guide](https://opentofu.org/docs/intro/install/).

### Find the module files

The OpenTofu module is stored in this repository at:

```text
docs/install/bootstrap-node/
├── main.tf
├── variables.tf
├── outputs.tf
├── cloud-config.tftpl
└── tofu.tfvars.example
```

These files are intentionally not separate navigation entries. If you cloned
the repository, change to the module directory:

```bash
cd nkp-collection/docs/install/bootstrap-node
```

If you are reading the rendered documentation without a local clone, download
all five files below and place them in the same directory:

- [`main.tf`](main.tf)
- [`variables.tf`](variables.tf)
- [`outputs.tf`](outputs.tf)
- [`cloud-config.tftpl`](cloud-config.tftpl)
- [`tofu.tfvars.example`](tofu.tfvars.example)

!!! note
    Do not copy only `main.tf`. It references variables and the
    `cloud-config.tftpl` template from the same directory.

### Configure the module

From the module directory:

```bash
cp tofu.tfvars.example tofu.tfvars
```

Edit `tofu.tfvars` and replace every example value.

!!! warning "Do not commit credentials"
    `tofu.tfvars` contains the Prism Central password and is ignored by Git.
    Keep it local and use your organization's secret-management process for
    shared automation.

### Initialize and review

```bash
tofu init
tofu fmt -check
tofu validate
tofu plan -var-file=tofu.tfvars
```

Review the plan before creating the VM.

### Create the bootstrap node

```bash
tofu apply -var-file=tofu.tfvars
```

After cloud-init completes, refresh the state and display the address:

```bash
tofu refresh -var-file=tofu.tfvars
tofu output vm_ip_address
```

Connect with SSH:

```bash
ssh nutanix@<bootstrap-ip>
```

## Option 2: Prepare a host manually

You can use an existing Linux or macOS host. It does not have to run on Nutanix
AHV. Keep it available until management-cluster creation and the Cluster API
pivot have completed.

### Optional: create a Linux VM on AHV

In Prism Central:

1. Create a VM from the Ubuntu 24.04 cloud image.
2. Assign at least 4 vCPUs, 8 GiB memory, and a 100 GiB disk.
3. Attach the VM to the bootstrap subnet.
4. Enable DHCP or assign an address according to your network design.
5. Add a non-root administrative user and your SSH public key with cloud-init or
   the image customization options.
6. Start the VM and connect over SSH.

### Ubuntu example

The commands below prepare Ubuntu 24.04. Adapt the package-manager and repository
steps for another Linux distribution.

```bash
sudo apt-get update
sudo apt-get install -y \
  apt-transport-https ca-certificates curl git gnupg jq \
  software-properties-common unzip
```

Install Docker:

```bash
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "${VERSION_CODENAME}") stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
sudo usermod -aG docker "${USER}"
```

Log out and reconnect so the Docker group membership takes effect.

Install `kubectl` 1.35:

```bash
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.35/deb/Release.key \
  | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo \
  "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.35/deb/ /" \
  | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubectl
```

Install `yq`:

```bash
sudo curl -fsSL \
  https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 \
  -o /usr/local/bin/yq
sudo chmod 0755 /usr/local/bin/yq
```

### macOS example

Install Docker Desktop or another compatible Linux-container runtime. With
[Homebrew](https://brew.sh/) installed:

```bash
brew install kubectl yq jq git
```

Start Docker and verify that Linux containers run before invoking the NKP CLI.
Download the NKP CLI build that matches macOS and the Mac's CPU architecture.

For an air-gapped bootstrap node, mirror these packages and binaries internally
instead of running the public download commands.

## Verify the bootstrap node

For either method:

```bash
docker version
kubectl version --client
yq --version
git --version
jq --version
```

For the OpenTofu method, check `/var/log/cloud-init-output.log` if provisioning
is incomplete.

!!! tip "Field note: keep the VM until the pivot completes"
    Do not destroy the bootstrap VM while management-cluster creation is in
    progress. The temporary kind cluster contains the Cluster API controllers
    and conditions needed for troubleshooting.

## Remove the bootstrap node

After the management cluster is healthy and all required files have been copied
off the VM, delete it manually or use OpenTofu:

```bash
tofu destroy -var-file=tofu.tfvars
```

