# Build a custom image: air-gapped

In an air-gapped environment the temporary build VM cannot download operating
system packages. You therefore split the work in two:

1. On a host **with** internet access, create a **package bundle**.
2. Move the bundle into the restricted network and build the image there.

> Based on the NKP 2.18 and 2.19 documentation. Not yet tested end to end.

Read [Build a custom image](custom-connected.md) first. The licence, base image,
and Prism Central requirements are the same.

## Before you begin

You need:

- the NKP air-gapped bundle from the Nutanix Support Portal, extracted on both
  the connected host and the bootstrap host;
- an internet-connected Linux or macOS AMD64 host with Docker or Podman for the
  package bundle step. It needs access to the operating system vendor's package
  repositories. Check the vendor documentation for the endpoints to allow;
- a base image imported into Prism Central, as described in the
  [base image requirements](custom-connected.md#base-image-requirements);
- a bootstrap host inside the restricted network.

## Step 1: Create the package bundle (connected host)

```bash
tar -xzvf nkp-air-gapped-bundle_v2.19.0_linux_amd64.tar.gz
cd nkp-v2.19.0
sudo install -m 0755 ./cli/nkp /usr/local/bin/nkp

docker load -i konvoy-bootstrap-image-v2.19.0.tar
docker load -i nkp-image-builder-image-v2.19.0.tar
```

```bash
export OS=ubuntu-24.04
export OS_BUNDLE_DIR=artifacts

nkp create package-bundle \
  --artifacts-directory "${OS_BUNDLE_DIR}" \
  "${OS}"
```

For a FIPS image, add `--fips` here **and** when you build the image.

The command writes the operating system packages as a `.tar.gz` file into
`OS_BUNDLE_DIR`.

## Step 2: Transfer the bundle

Copy the contents of `OS_BUNDLE_DIR` into the restricted network. This is also
the point to run your malware scan or approval process on the file.

You also need the base image in Prism Central, and the NKP air-gapped bundle
extracted on the bootstrap host.

## Step 3: Build the image (bootstrap host)

Load the image builder container on the bootstrap host:

```bash
docker load -i nkp-image-builder-image-v2.19.0.tar
```

Set the environment:

```bash
export OS=ubuntu-24.04
export OS_BUNDLE_DIR=artifacts
export BASE_IMAGE=ubuntu-24.04-server-cloudimg-amd64.img

export NUTANIX_ENDPOINT=pc.example.com
export NUTANIX_PRISM_ELEMENT_CLUSTER_NAME=PE-CLUSTER
export NUTANIX_SUBNET_NAME=PRIMARY-NETWORK

export NUTANIX_USER=admin
read -r -s -p "Prism Central password: " NUTANIX_PASSWORD
export NUTANIX_PASSWORD
echo
```

Build:

```bash
nkp create image nutanix "${OS}" \
  --endpoint "${NUTANIX_ENDPOINT}" \
  --cluster "${NUTANIX_PRISM_ELEMENT_CLUSTER_NAME}" \
  --subnet "${NUTANIX_SUBNET_NAME}" \
  --source-image "${BASE_IMAGE}" \
  --artifacts-directory "${OS_BUNDLE_DIR}"
```

`--artifacts-directory` tells the builder to use your local package bundle
instead of fetching packages from the internet. Always provide `--source-image`
in an air-gapped environment, because the builder cannot download a base image.

Record the printed image name in `NUTANIX_MACHINE_TEMPLATE_IMAGE_NAME` and use
it in the
[air-gapped management cluster guide](../install/v2.19/airgapped/management-cluster.md).

## Optional: build through a bastion host

When the bootstrap host cannot reach the build VM directly, the CLI can connect
through a bastion host:

```bash
nkp create image nutanix "${OS}" \
  --endpoint "${NUTANIX_ENDPOINT}" \
  --cluster "${NUTANIX_PRISM_ELEMENT_CLUSTER_NAME}" \
  --subnet "${NUTANIX_SUBNET_NAME}" \
  --source-image "${BASE_IMAGE}" \
  --artifacts-directory "${OS_BUNDLE_DIR}" \
  --bastion-host bastion.example.com \
  --bastion-username ubuntu \
  --bastion-private-key-file "$HOME/.ssh/bastion_ed25519"
```

## Optional: embed container images

`--bundle` loads container image tarballs into the OS image, which can shorten
first-boot time because the node does not have to pull them. Pass one or more
`.tar` files, comma-separated:

```bash
  --bundle ./container-images/konvoy-image-bundle-v2.19.0.tar
```

!!! tip "Field note: rebuild the package bundle for every build"
    The package bundle reflects the repository contents on the day you created
    it. Create a fresh bundle when you rebuild an image for a new Kubernetes
    patch release, so the image and the bundle stay in step.
