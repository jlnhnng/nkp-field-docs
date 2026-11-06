# Use a pre-built image

Nutanix publishes ready-to-use node images for AHV. They are the quickest way to
a working cluster and are available on every NKP licence tier.

## Before you begin

You need:

- access to the [Nutanix Support Portal](https://portal.nutanix.com/page/downloads?product=nkp);
- Prism Central access with permission to upload images;
- a licence for NKP Starter, Pro, or Ultimate.

Pre-built images are published for Rocky Linux and Ubuntu. Starter customers use
the Rocky Linux image. Pro and Ultimate customers can also use the Ubuntu image.

## Download the image

1. Open the NKP download page on the Nutanix Support Portal.
2. In the product drop-down at the top of the page, change **NKP** to
   **NKP Operating System Images**.
3. Select the NKP version you run or plan to upgrade to.
4. Download the image for your operating system.

!!! warning "Do not rename the file"
    NKP refers to the image by name. Keep the filename exactly as downloaded
    when you upload it to Prism Central.

## Upload to Prism Central

Upload the file with the Prism Central image import workflow, or with the API or
OpenTofu if you automate Prism. Wait until the image state is **Active**.

## Use it when creating a cluster

Record the image name and pass it to the cluster creation command:

```bash
export NUTANIX_MACHINE_TEMPLATE_IMAGE_NAME=nkp-rocky-9.8-release-cis-1.36.2.qcow2
```

```bash
nkp create cluster nutanix -c "${CLUSTER_NAME}" \
  --control-plane-vm-image "${NUTANIX_MACHINE_TEMPLATE_IMAGE_NAME}" \
  --worker-vm-image "${NUTANIX_MACHINE_TEMPLATE_IMAGE_NAME}" \
  ...
```

The remaining flags are in the
[management cluster guide](../install/v2.19/standard/management-cluster.md).

!!! info "What you get"
    The pre-built operating system layer is hardened to CIS Level 1, and the NKP
    and Kubernetes components follow CIS Level 2 guidance. Custom images are not
    CIS-hardened by the standard build.

## When to build your own instead

Build a [custom image](custom-connected.md) if you need FIPS, your own base
configuration or agents, or GPU drivers on an operating system whose pre-built
image does not include them.

!!! warning "Pre-built images cannot be a base image"
    You cannot use a downloaded pre-built image, or an image produced by an
    earlier NIB build, as the base image for a new build. Start from an upstream
    cloud image or an image you built from an ISO.
