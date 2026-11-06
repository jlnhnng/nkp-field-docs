# Create a workspace

> Tested with NKP 2.18.0

A workspace groups clusters, platform applications, and access controls. Create
it before creating the first workload cluster.

## Before you begin

You need a running management cluster, its kubeconfig, and permission to create
workspace resources.

## Configure the workspace

```bash
export MANAGEMENT_KUBECONFIG="$HOME/nkp-mgmt-cluster.conf"
export WORKSPACE_NAME=dev-workspace
export WORKSPACE_DISPLAY_NAME="Development"
```

`WORKSPACE_NAME` becomes the resource name and namespace. Use a DNS-compatible
name.

## Create the workspace

```bash
cat <<EOF | kubectl --kubeconfig "${MANAGEMENT_KUBECONFIG}" apply -f -
apiVersion: workspaces.kommander.mesosphere.io/v1alpha1
kind: Workspace
metadata:
  name: ${WORKSPACE_NAME}
  annotations:
    kommander.mesosphere.io/display-name: ${WORKSPACE_DISPLAY_NAME}
spec:
  namespaceName: ${WORKSPACE_NAME}
EOF
```

## Verify the workspace

```bash
kubectl --kubeconfig "${MANAGEMENT_KUBECONFIG}" get workspace "${WORKSPACE_NAME}"
kubectl --kubeconfig "${MANAGEMENT_KUBECONFIG}" get namespace "${WORKSPACE_NAME}"
```

!!! tip "Field note: use durable boundaries"
    Use workspaces for long-lived ownership or governance boundaries. Use
    projects to organize application teams.

## Next step

[Create a workload cluster](workload-cluster.md).
