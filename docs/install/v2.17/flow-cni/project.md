# Create a project

> Tested with NKP 2.17.1 · Flow CNI path

```bash
export MANAGEMENT_KUBECONFIG="$HOME/nkp-mgmt-cluster.conf"
export WORKSPACE_NAME=dev-workspace
export CLUSTER_NAME=nkp-dev-cluster
export PROJECT_NAME=demo-project

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
        environment: dev
EOF

kubectl --kubeconfig "${MANAGEMENT_KUBECONFIG}" \
  label cluster "${CLUSTER_NAME}" environment=dev -n "${WORKSPACE_NAME}"
```

Verify:

```bash
kubectl --kubeconfig "${MANAGEMENT_KUBECONFIG}" \
  get project "${PROJECT_NAME}" -n "${WORKSPACE_NAME}"
kubectl --kubeconfig "${MANAGEMENT_KUBECONFIG}" \
  get cluster "${CLUSTER_NAME}" -n "${WORKSPACE_NAME}" --show-labels
```

Validate project application connectivity and network policies on Flow CNI.
