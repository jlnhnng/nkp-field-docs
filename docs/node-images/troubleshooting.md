# Troubleshoot image builds

This page lists the checks that resolve most failed builds. It is general
guidance based on how the builder works. It does not replace the Nutanix
documentation or a support case.

## Before you rerun a build

1. Run the same command with `--dry-run` to separate connection problems from
   build problems.
2. Check Prism Central for a leftover temporary VM from the failed run, and for
   a partial image. Remove them if they are no longer needed.
3. Rerun with `--debug` in an interactive terminal to stop after each step.

## Common causes

| Symptom | Check |
| --- | --- |
| Cannot connect to Prism Central | Endpoint format (`host`, `host:port`, or URL), port 9440, credentials, and whether the certificate is trusted. Use `--insecure` only in labs. |
| Build VM never gets an address | The subnet must belong to the selected Prism Element cluster and provide DHCP or IPAM. |
| Build VM boots but the builder cannot connect | The bootstrap host must reach the VM's subnet. Use a bastion host with `--bastion-*` when it cannot. |
| Package download fails (connected build) | DNS resolution and access to the operating system's package repositories from the build VM. |
| Package install fails (air-gapped build) | `--artifacts-directory` points at the package bundle, and the bundle was created for the same operating system, Kubernetes version, and FIPS setting. |
| Base image rejected or build fails early | Verify the [base image requirements](custom-connected.md#base-image-requirements): UEFI, sudo user, SSH, cloud-init, Python 3, 20 GB free, no Kubernetes packages. |
| Build fails with a pre-built image as the base | Use an upstream cloud image or an ISO-based image instead. NKP images cannot be a base. |
| Image builder container not found | In air-gapped mode, run `docker load` for the `nkp-image-builder` image from the NKP bundle. |
| Cluster creation cannot find the image | The name passed to `--control-plane-vm-image` and `--worker-vm-image` must match the image name in Prism Central exactly. |

## Escalate with the right information

Ask the **Nutanix Intelligent Virtual Agent (NIVA)** or search the NKP
documentation on the support portal first. If the problem remains, open a
support case and include:

- the NKP CLI version (`nkp version`) and the full command, without passwords;
- the operating system and base image name;
- whether the build is air-gapped and whether `--fips`, GPU, or `--overrides`
  were used;
- the terminal output of the failed run, including `--debug` output if you have
  it.

## Related guides

- [Build a custom image](custom-connected.md)
- [Build a custom image: air-gapped](custom-airgapped.md)
- [Support bundle](../troubleshooting/support-bundle.md)
