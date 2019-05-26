# Kubernetes kubeadm setup:
This guide describes how to standup a single node `Kubernetes` cluster running `Flannel`

## Instructions
1) Run the following command to stand up the cluster:
    ```bash
    kubeadm init --hostname-override --node-name kube-home --pod-network-cidr=10.244.0.0/16
    ```

1) Set `KUBE_CONFIG` environment variable to interface with `kubectl`:
    ```bash
    export KUBECONFIG=/etc/kubernetes/admin.conf
    ```

1) Pass bridged IPv4 traffic to iptables’ chains
    ```bash
    sysctl net.bridge.bridge-nf-call-iptables=1
    ```

1) Install `Flannel`:
    ```bash
    kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/62e44c867a2846fefb68bd5f178daf4da3095ccb/Documentation/kube-flannel.yml
    ```

1) Schedule all pods of `master`:
    ```bash
    kubectl taint nodes --all node-role.kubernetes.io/master-
    ```

### Fix loopback issue

# Deploying Helm:
Since [`Home Assistant`](https://www.home-assistant.io/) and a few other services have `Helm` charts, install `Helm`.

1) Install `GoFish`:
    https://gofi.sh/index.html#install

1) Install Helm:
    ```bash
    gofish install helm
    ```

## Install ‘tiller’

1) Deploy `tiller`:
    ```bash
    kubectl create -f system/tiller/rbac-config.yaml
    ```

1) Initialize `Helm`:
    ```bash
    helm init --service-account tiller --history-max 200
    ```

## Install `MetalLB`

1) Install `MetalLB`:
    ```
    kubectl apply -f https://raw.githubusercontent.com/google/metallb/v0.7.3/manifests/metallb.yaml
    ```

1) Configure `MetalLB`:
    ```bash
    kubectl create -f metallb/metallb/config.yaml
    ```

Please note, this has been built with versions:

kube: v1.14.0
helm: v2.13.0

# Uninstall `Kubernetes`
To uninstall the `Kubernetes` cluster completely, run the following commands:

1) Drain and delete the node
    ```
    kubectl drain kube-home --delete-local-data --force --ignore-daemonsets
    kubectl delete node kube-home
    ```

1) Reset all `kubeadm` installed state:
    ```
    kubeadm reset
    ```

1) Reset IP tables:
    ```
    iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X
    ```

# Troubleshooting:

To simplfy `Helm` install/uninstall:
https://medium.com/@pczarkowski/easily-install-uninstall-helm-on-rbac-kubernetes-8c3c0e22d0d7

# Validating setup:
### In order to ensure that layer 2 is setup. Follow this guide:
https://metallb.universe.tf/tutorial/layer2/

### When asked to create ‘example-layer2-config.yaml’ use the following instead:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: my-ip-space
      protocol: layer2
      addresses:
      - 192.168.29.100-192.168.29.254

End
```

# References

### Installing `Kubernetes`
https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/

### Fix loopback issue
https://github.com/coredns/coredns/issues/2087
https://coredns.io/plugins/loop/#troubleshooting

### Installing `Helm` + `tiller`
https://helm.sh/docs/using_helm/#tiller-and-role-based-access-control

### Installing `MetalLB`
https://metallb.universe.tf/tutorial/layer2/
