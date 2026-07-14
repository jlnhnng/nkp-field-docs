# Create a project

> Tested with NKP 2.17.1

A project provides an application namespace and configuration boundary across
selected clusters in one workspace.

## Configure the project

```bash
export MANAGEMENT_KUBECONFIG="$HOME/nkp-mgmt-cluster.conf"
export WORKSPACE_NAME=dev-workspace
export CLUSTER_NAME=nkp-dev-cluster
export PROJECT_NAME=demo-project
export PROJECT_LABEL=environment
export PROJECT_LABEL_VALUE=dev
```

## Create and assign the project

```bash
cat <<EOF | kubectl --kubeconfig "${MANAGEMENT_KUBECONFIG}" apply -f -
apiVersion: workspaces.kommander.mesosphere.io/v1alpha1
kind: Project
metadata:
  name: ${PROJECT_NAME}
  namespace: ${WORKSPACE_NAME}
spec:
  namespaceName: ${PROJECT_NAME}
  placement:
    clusterSelector:
      matchLabels:
        ${PROJECT_LABEL}: ${PROJECT_LABEL_VALUE}
EOF

kubectl --kubeconfig "${MANAGEMENT_KUBECONFIG}" \
  label cluster "${CLUSTER_NAME}" \
  "${PROJECT_LABEL}=${PROJECT_LABEL_VALUE}" \
  -n "${WORKSPACE_NAME}"
```

## Verify the project

```bash
kubectl --kubeconfig "${MANAGEMENT_KUBECONFIG}" \
  get project "${PROJECT_NAME}" -n "${WORKSPACE_NAME}"
kubectl --kubeconfig "${MANAGEMENT_KUBECONFIG}" \
  get cluster "${CLUSTER_NAME}" -n "${WORKSPACE_NAME}" --show-labels
```
