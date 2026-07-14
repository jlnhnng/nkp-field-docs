# Create a project

> Tested with NKP 2.18.0

A project gives an application team a consistent namespace and configuration
boundary across selected clusters in one workspace.

## Configure the project

```bash
export MANAGEMENT_KUBECONFIG="$HOME/nkp-mgmt-cluster.conf"
export WORKSPACE_NAME=dev-workspace
export CLUSTER_NAME=nkp-dev-cluster
export PROJECT_NAME=demo-project
export PROJECT_LABEL=environment
export PROJECT_LABEL_VALUE=dev
```

## Create the project

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
```

## Assign the cluster

```bash
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

Confirm that the project namespace appears on the selected workload cluster.

!!! tip "Field note: describe the cluster with labels"
    Prefer stable labels such as environment, region, and compliance boundary.
    Avoid labels that couple a cluster to only one project.
