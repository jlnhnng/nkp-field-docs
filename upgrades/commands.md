# Upgrade NKP
Last update: `May 12 2026`

This guide shows how to upgrade the Nutanix Kubernetes Platform from `v2.17.0` to `v2.17.1`.

## GitOps
If you manage your clusters via GitOps (using FluxCD, which is built into NKP), you cannot use imperative CLI commands like `nkp upgrade cluster`. If you did, the CLI would tell the cluster to upgrade, but Flux would immediately see that the live cluster no longer matches the configuration stored in Git. Flux might then attempt to "fix" the cluster by downgrading it back to the older version, causing massive conflicts.

BUT `nkp upgrade kommander` and `workspace` are still required to run manual before starting the upgrade process via GitOps.

### The GitOps Upgrade Workflow
Instead of typing nkp upgrade cluster nutanix --cluster-name my-cluster --vm-image my-new-image into your terminal, you perform the upgrade by editing code:

1. **Open your Git Repository**: Go to the repository where your cluster configurations are stored.
2. **Edit the NKPCluster YAML**: Find the YAML file for the cluster you want to upgrade. You will manually change the target versions in the text. For example:
    - Change version: v1.33.0 to version: v1.34.1
    - Update the OS image reference in the variables section to point to your newly uploaded Rocky Linux image.
3. **Commit and Push**: Save the file, commit the change, and push it to your Git server (e.g., GitHub, GitLab, Bitbucket).
4. **Flux Takes Over**: The FluxCD agent running on your management cluster constantly polls that Git repository. It will detect your commit, pull down the new NKPCluster YAML, and apply it to the cluster.
5. **Rolling Upgrade**: NKP’s Cluster API (CAPI) controllers see the new desired state. They will automatically spin up new nodes with the new OS image and Kubernetes version, move your workloads over, and delete the old nodes one by one.

## CLI

### 1. Upgrade Kommander

You need to have access to the management cluster and have the kubeconfig file configured. Alternatively you can use the flag `--kubeconfig` with the kubeconfig from the management cluster.

Download latest nkp cli version from support portal:
``` sh
### Download and install latest version
curl ... # Downloadlink
tar -xvzf <downloaded_file.tar.gz>
sudo mv ./nkp /usr/bin
nkp version


### Run the upgrade command
nkp upgrade kommander # "-v 6" for more information
```

Sample output:
```
✓ Running pre-flight checks
✓ Fetching applications repository
✓ Deploying base resources
✓ Persisting registry credentials for OCI Artifacts
✓ Deploying Flux
```

**Note**:
> `nkp upgrade` command upgrades all platform applications automatically in the kommander workspace namespace `kommander-workspace`

### 2. Upgrading Platform Applications on Managed and Attached Clusters

``` sh
# Get all workspaces
nkp get workspaces

# Select the workspace you want to upgrade
export WORKSPACE_NAME=default-workspace 
# export WORKSPACE_NAME=prod-01

# Upgrade it
nkp upgrade workspace ${WORKSPACE_NAME}
```

### 3. Prepare the Target Kubernetes VM Image

1. Download the target Rocky Linux Kubernetes VM image matching the upgraded NKP version from the Nutanix Portal (https://portal.nutanix.com/page/downloads?product=nkp).
2. Upload this image to Prism Central -> Images.
3. Note the image name for the next steps.

### 4. Upgrade Management Cluster
``` sh
# Create variables for the cluster upgrades
export MANAGEMENT_CLUSTER_NAME=nkp
export VM_IMAGE_NAME=nkp-rocky-9.7-release-cis-1.34.3-20260504011927.qcow2

# Upgrade the management cluster
nkp upgrade cluster nutanix \
      --cluster-name ${MANAGEMENT_CLUSTER_NAME} \
      --vm-image ${VM_IMAGE_NAME}
```

### 5. Upgrade Managed Cluster
``` sh
# Check which clusters are available
kubectl get cluster -A

# Create variables for the cluster upgrades
export WORKLOAD_CLUSTER_NAME=prod-01
export WORKLOAD_CLUSTER_NAMESPACE=prod-01
export VM_IMAGE_NAME=nkp-rocky-9.7-release-cis-1.34.3-20260504011927.qcow2

# Upgrade the managed cluster
nkp upgrade cluster nutanix \
--cluster-name ${WORKLOAD_CLUSTER_NAME} \
--vm-image ${VM_IMAGE_NAME} -n ${WORKLOAD_CLUSTER_NAMESPACE}
```

### Useful commands for the upgrade process
``` sh
kubectl get clusters -A
```