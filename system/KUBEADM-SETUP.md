# Kubernetes kubeadm setup:
This guide describes how to standup a single node `Kubernetes` cluster running `Flannel`

## Preflight
The following must be installed/configured prior:

```
docker-ce
kubeadm
swap
iptables
```

### Installing `docker-ce`
Please note, installing `docker-ce` is required for getting `NVIDIA` GPU support working

1) Install dependencies (may already be installed)

```
sudo yum install yum-utils \
  device-mapper-persistent-data \
  lvm2
```

1) Setup stable repository

```
sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
```

1) Install `docker-ce`

```
sudo yum install docker-ce docker-ce-cli containerd.io
```

1) Start `docker-ce`

```
sudo systemctl start docker
```

### Installing `kubeadm`

`kubeadm` must be installed:
1) Install the repo

    ```
    cat <<EOF > /etc/yum.repos.d/kubernetes.repo
    [kubernetes]
    name=Kubernetes
    baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
    enabled=1
    gpgcheck=1
    repo_gpgcheck=1
    gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
    exclude=kube*
    EOF
    ```

1) Disable SE Linux

    ```
    setenforce 0
    ```

1) Install `kubeadm` and related packages:

    ```
    yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
    ```

1) Enable `kubelet`:

    ```
    systemctl enable --now kubelet
    ```

### Disable swap

Swap must be disabled
1) Disable Swap for current runtime

    ```
    swapoff -a
    ```

1) Remove swap references in `/etc/fstab`

    ```
    vi /etc/fstab
    ```

    Comment out line referencing swap

### Modify iptables

Disable `kube` traffic going through `iptables`:

    ```
    echo '' >> /etc/sysctl.conf
    echo 'net.bridge.bridge-nf-call-iptables = 1' >> /etc/sysctl.conf
    sudo sysctl -p
    ```

## Instructions
1) Run the following command to stand up the cluster:
    ```bash
    kubeadm init --node-name kube-home --pod-network-cidr=10.244.0.0/16
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
In some installs `CoreDNS` pods will report `CrashLoopBackOff` with the following `kubectl log ..` error message:

```
2019-05-29T21:08:01.525Z [FATAL] plugin/loop: Loop (127.0.0.1:43211 -> :53) detected for zone ".", see https://coredns.io/plugins/loop#troubleshooting. Query: "HINFO 679688347533153169.846261181708532630."
```

In order to resolve this perform the following steps:

1) Edit `CoreDNS` configmap:

    ```bash
    kubectl -n kube-system edit configmap coredns
    ```
    
    Remove line that includes the word `loop`
   
    Wait for change to propogate through to `coredns` pods


### Fix resolv issue (for ClearOS)
[ClearOS](https://www.clearos.com/) uses a unique `resolv.conf` file for resolutions. The default `/etc/resolv.conf` file contains localhost references which will cause `CoreDNS` pods to be `OOMKilled`. To fix this, follow these steps:

1) Determine location of `kubelet` config file:
    ```bash
    ps -ex | grep kubelet
    ```
    
    _Note, this will be the file found immediately after `--config`. In my case it was `/var/lib/kubelet/config.yaml`_

1) Update `resolv.conf` file:

    Identify the line found in the config file (in my case it was `/var/lib/kubelet/config.yaml`):
    
    ```bash
    ...
    resolvConf: /etc/resolv.conf
    ...
    ```
    
    Update it to:

    ```bash
    ...
    resolvConf: /etc/resolv-peerdns.conf
    ...
    ```
    
1) Restart `kubelet`:

    ```bash
    systemctl restart kubelet
    ```

Follow the next subsection for updating `CoreDNS`

##### Update `CoreDNS` to `1.5.0`
It appears the version of `CoreDNS` that comes with `kubeadmin` version `1.14` has an issue with loading overridden `resolvConf:` in the `kubelet` config file (like what was outlined in the previous section). In order address this, `CoreDNS` must be updated to a later version.

1) Edit the `CoreDNS` deployment:

    ```bash
    kubectl edit deployment coredns -n kube-system
    ```
    
    Modify the image from:
    
    ```bash
    ...
    image: k8s.gcr.io/coredns:1.3.1
    ...
    ```
    
    To:
    
    ```bash
    ...
    image: k8s.gcr.io/coredns:1.5.0
    ...
    ```
    
    Save and wait for `CoreDNS` pods to rebuild.

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
    kubectl create -f system/metallb/config.yaml
    ```

Please note, this has been built with versions:

kube: v1.15.0
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

See the following link for more information:

https://github.com/kubernetes/kubernetes/issues/62594

# References

### Installing `docker-ce`
https://docs.docker.com/install/linux/docker-ce/centos/

### Installing `Kubernetes`
https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/

### Fix loopback issue
https://github.com/coredns/coredns/issues/2087
https://coredns.io/plugins/loop/#troubleshooting

### Installing `Helm` + `tiller`
https://helm.sh/docs/using_helm/#tiller-and-role-based-access-control

### Installing `MetalLB`
https://metallb.universe.tf/tutorial/layer2/

### Fix `CoreDNS` on `ClearOS`
https://stackoverflow.com/questions/52645473/coredns-fails-to-run-in-kubernetes-cluster?rq=1
