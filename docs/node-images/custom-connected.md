# Build a custom image

This guide builds an NKP node image on Nutanix AHV from a host with internet
access. For an environment without internet access, use
[Build a custom image: air-gapped](custom-airgapped.md).

## Before you begin

You need:

- an **NKP Pro or Ultimate** licence. Custom images are not supported on Starter;
- a bootstrap host with the `nkp` CLI and Docker or Podman. See
  [Prepare a bootstrap node](../install/bootstrap-node/index.md). The host must
  run Linux or macOS on AMD64;
- Prism Central credentials and network access to Prism Central on port 9440;
- a Prism Element cluster and a subnet in that cluster with DHCP or IPAM, DNS
  resolution, and access to the operating system's package repositories.

### Base image requirements

The builder starts from a base image that you import into Prism Central first.
The base image must:

- be in `qcow2` or `.img` format;
- boot with **UEFI**;
- have a default user with `sudo` privileges;
- have an SSH server installed and enabled;
- have cloud-init installed and configured;
- have Python 3 installed and on the path;
- have at least 20 GB free on the root filesystem;
- have swap disabled and a sufficiently large `/var`;
- have no Kubernetes components installed.

If you build the base image from an ISO or an existing VM, apply your
organisation's standard configuration first, such as NTP, DNS, certificates, and
hardening, so it is already present in the base.

!!! warning "Do not use an NKP image as the base"
    Pre-built images from the Nutanix Support Portal and images created by an
    earlier `nkp create image` run cannot be used as a base image.

For the upstream cloud images, use the generic cloud image of the operating
system you build. For example, `ubuntu-24.04-server-cloudimg-amd64.img` for
Ubuntu 24.04. Upload it to Prism Central and wait for it to become **Active**.

For RHEL 8.10 you must always provide a source image.

## Configure the environment

```bash
export OS=ubuntu-24.04
export BASE_IMAGE=ubuntu-24.04-server-cloudimg-amd64.img

export NUTANIX_ENDPOINT=pc.example.com
export NUTANIX_PORT=9440
export NUTANIX_PRISM_ELEMENT_CLUSTER_NAME=PE-CLUSTER
export NUTANIX_SUBNET_NAME=PRIMARY-NETWORK

export NUTANIX_USER=admin
read -r -s -p "Prism Central password: " NUTANIX_PASSWORD
export NUTANIX_PASSWORD
echo
```

Replace the example values. `BASE_IMAGE` is the name or UUID of the image you
imported into Prism Central.

!!! info "Choose the operating system value"
    The supported values for `OS` depend on the NKP release. List them with
    `nkp create image nutanix --help` on your CLI version, and compare with the
    [supported operating systems](index.md#supported-operating-systems).

## Run a dry run first

```bash
nkp create image nutanix "${OS}" \
  --endpoint "${NUTANIX_ENDPOINT}" \
  --port "${NUTANIX_PORT}" \
  --cluster "${NUTANIX_PRISM_ELEMENT_CLUSTER_NAME}" \
  --subnet "${NUTANIX_SUBNET_NAME}" \
  --source-image "${BASE_IMAGE}" \
  --dry-run
```

A dry run does not keep the artifacts. It catches connection, credential, and
parameter mistakes before you spend a full build on them.

Add `--insecure` only in a lab where Prism Central uses a certificate that the
bootstrap host does not trust.

## Build the image

Run the same command without `--dry-run`:

```bash
nkp create image nutanix "${OS}" \
  --endpoint "${NUTANIX_ENDPOINT}" \
  --port "${NUTANIX_PORT}" \
  --cluster "${NUTANIX_PRISM_ELEMENT_CLUSTER_NAME}" \
  --subnet "${NUTANIX_SUBNET_NAME}" \
  --source-image "${BASE_IMAGE}"
```

The builder creates a temporary VM, configures it, and uploads the result to
Prism Central. If you omit `--source-image`, the builder downloads the upstream
base image for the operating system.

The Kubernetes version defaults to the version bundled with your CLI. Set
`--kubernetes-version` only when you need to build for a specific version.

## Record the image name

When the build completes, the command prints the image name, for example:

```text
nkp-ubuntu-24.04-1.36.2-20260101120000
```

Confirm the image is **Active** in Prism Central, then use it for cluster
creation:

```bash
export NUTANIX_MACHINE_TEMPLATE_IMAGE_NAME=nkp-ubuntu-24.04-1.36.2-20260101120000
```

Pass `NUTANIX_MACHINE_TEMPLATE_IMAGE_NAME` to `--control-plane-vm-image` and
`--worker-vm-image` in the
[management cluster guide](../install/standard/management-cluster.md).

!!! tip "Field note: name builds so you can find them"
    Use `--extra-build-name` to add a suffix, such as the team or a change
    ticket, to the image name. Several images with the same Kubernetes version
    are hard to tell apart in Prism Central otherwise.

## Next step

Customize the build with [FIPS, GPU, and naming options](customization.md), or
go back to [Installation](../install/index.md).
