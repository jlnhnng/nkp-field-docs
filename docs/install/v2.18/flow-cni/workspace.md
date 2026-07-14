# Create a workspace

> Tested with NKP 2.18.0 · Flow CNI path

The workspace procedure does not change when the management cluster uses Flow
CNI.

## Create the workspace

```bash
export MANAGEMENT_KUBECONFIG="$HOME/nkp-mgmt-cluster.conf"
export WORKSPACE_NAME=dev-workspace
export WORKSPACE_DISPLAY_NAME="Development"

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

## Next step

[Create a workload cluster with Flow CNI](workload-cluster.md).
