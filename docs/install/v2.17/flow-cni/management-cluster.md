# Create a management cluster with Flow CNI

> Tested with NKP 2.17.1

Flow CNI replaces the default Cilium configuration before the cluster manifest
is applied. Use the [NKP 2.18 Flow CNI procedure](../../v2.18/flow-cni/management-cluster.md)
as the command reference, with the release-specific values below.

## Release-specific values

```bash
export NKP_VERSION=2.17.1
export NKP_BUNDLE=nkp-bundle_v2.17.1_linux_amd64.tar.gz
export NKP_NODE_IMAGE=nkp-ubuntu-24.04-release-cis-1.34.3.qcow2
export FLOW_CHART_VERSION=1.3.0
```

Install the matching CLI and bootstrap image:

```bash
tar -xzvf "${NKP_BUNDLE}"
sudo install -m 0755 \
  "./nkp-v${NKP_VERSION}/cli/nkp" \
  /usr/local/bin/nkp
docker load --input \
  "nkp-v${NKP_VERSION}/konvoy-bootstrap-image-v${NKP_VERSION}.tar"
```

## Required workflow

1. Generate the NKP 2.17.1 cluster manifest with `--dry-run -o yaml`.
2. Remove `.spec.topology.variables[0].value.addons.cni` from the `Cluster`.
3. Obtain `caren.nutanix.com/cluster-uuid` from the generated `Cluster`.
4. Append a `HelmChartProxy` for `nutanix-flow-cni` version
   `${FLOW_CHART_VERSION}`.
5. Apply the complete manifest with server-side apply.
6. Verify the `flow-cni-system` pods before installing applications.

Use non-overlapping networks:

```bash
export POD_CIDR=172.20.0.0
export SERVICE_CIDR=172.21.0.0
```

Pass `${POD_CIDR}/16` and `${SERVICE_CIDR}/16` to `nkp create cluster`. Use
`${POD_CIDR}/24` for the Flow CNI `podNetwork` value.

## Verify

```bash
kind get kubeconfig --name konvoy-capi-bootstrapper > bootstrap-cluster.conf
kubectl --kubeconfig bootstrap-cluster.conf get helmchartproxy -A
kubectl --kubeconfig bootstrap-cluster.conf get clusters,machines -A

kubectl --kubeconfig nkp-mgmt-cluster.conf get nodes
kubectl --kubeconfig nkp-mgmt-cluster.conf get pods -n flow-cni-system
```

!!! warning
    Do not mix the NKP 2.18 CLI or node image with this 2.17.1 procedure.

## Next step

[Create a workspace](workspace.md).
