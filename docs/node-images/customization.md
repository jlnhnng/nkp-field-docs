# Customize an image

These options extend the basic [connected](custom-connected.md) and
[air-gapped](custom-airgapped.md) builds. Add them to the `nkp create image
nutanix` command.

!!! tip "Keep it simple"
    Every customization is something you maintain. Use the options below, and
    ask Nutanix for guidance before going further. See
    [Where to get help](index.md#where-to-get-help).

## Common options

| Option | Purpose |
| --- | --- |
| `--fips` | Build a FIPS-compliant image. Also add it to `nkp create package-bundle` in air-gapped builds. |
| `--gpu-name` | Name of a GPU in the Prism Element cluster. The builder attaches it to the temporary VM and installs the GPU drivers. |
| `--vgpu-runfile` | Path to the NVIDIA vGPU driver runfile to install in the image. |
| `--extra-build-name` | Append text to the generated image name. |
| `--kubernetes-version` | Build for a specific Kubernetes version instead of the CLI default. |
| `--dry-run` | Validate the setup without keeping artifacts. |
| `--debug` | Run Packer in debug mode and pause after each step. |
| `--overrides` | Pass an override YAML file. See [Overrides](#overrides). |

Run `nkp create image nutanix --help` to see the options for your CLI version.

## FIPS

Add `--fips` to the build. For an air-gapped build, also create the package bundle
with `--fips`. In the NKP 2.18 support matrix, FIPS images are
available on RHEL only. Check the matrix for your release first.

```bash
nkp create image nutanix rhel-9.6 --fips \
  --source-image "${BASE_IMAGE}" \
  ...
```

## GPU and vGPU

GPU images are supported on Ubuntu and RHEL, not on Rocky Linux. vGPU images are
supported on Ubuntu and RHEL. For GPU
passthrough, add `--gpu-name` so the builder installs the driver:

```bash
nkp create image nutanix ubuntu-24.04 \
  --gpu-name "${GPU_NAME}" \
  ...
```

For vGPU, also pass the NVIDIA driver runfile with `--vgpu-runfile`. Download it
from NVIDIA with your licence.

## Overrides

`--overrides` accepts a YAML file. It is not a general extension mechanism: it only
changes variables that the selected image builder already uses. Keys it does not
know are ignored, and it does not run scripts.

Two uses are straightforward.

**Build-time proxy.** The proxy is used while the image builds and is not left
in the finished image.

```yaml title="proxy.yaml"
http_proxy: http://proxy.example.com:8080
https_proxy: http://proxy.example.com:8080
no_proxy: localhost,127.0.0.1,.cluster.local
```

```bash
nkp create image nutanix "${OS}" \
  ... \
  --overrides proxy.yaml
```

**Extra operating system packages.**

```yaml title="packages.yaml"
packages:
  extra_packages:
    - make
    - pkg-config
```

In an air-gapped build, pass the file when you create the package bundle so the
packages are included in it:

```bash
nkp create package-bundle \
  --artifacts-directory "${OS_BUNDLE_DIR}" \
  --overrides packages.yaml \
  "${OS}"
```

For anything else, ask Nutanix first. The portal documents custom overrides as
something to discuss with Nutanix Support.

## What custom images do not cover

These are not generic override keys, and adding them to a YAML file has no
effect:

| You want | Do this instead |
| --- | --- |
| CIS Level 1 hardening | Use the pre-built Rocky Linux or Ubuntu image. |
| NTP servers | Configure them when you create the cluster, or in your base image. |
| A corporate CA in the node trust store | Install it in the base image before the build. |
| Extra kernel parameters | Apply them in the base image, and confirm with Nutanix that the change is supported. |
| Registry CA and credentials | Use cluster creation options such as `--registry-mirror-cacert`. Do not bake credentials into an image. |

!!! warning "`--additional-trust-bundle` is not a node trust store"
    In NKP 2.18 the option covers Prism Central certificate validation. It does
    not add a CA to the operating system of cluster nodes.

If the builder itself must trust a TLS-inspecting proxy, configure that trust on
the machine that runs the builder. It is separate from what ends up in the image.

## Dry run and debug

Use `--dry-run` while you develop a build. Use `--debug` when a build fails and you
want to see each step. Run `--debug` in an interactive terminal, because it waits
for you after every step.

## Treat images like releases

Record the NKP CLI version, the exact command, the base image name, the package
bundle, and the resulting image name. When Kubernetes moves to a new version,
rebuild the image and roll it out.
