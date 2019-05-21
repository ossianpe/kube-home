# Kubernetes kubeadm setup:
In order to install `Kubernetes` follow the guide for `kubeadm`

https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/

For CNI, choose Flannel.

## For flannel, make sure to run:

```
kubeadm init -—pod-network-cidr=10.244.0.0/16
```

# Deploying Helm:
Since [`Home Assistant`](https://www.home-assistant.io/) and a few other services have `Helm` charts, install `Helm`.

1) Install `GoFish`: https://gofi.sh/index.html#install

1) Install Helm:

```bash
gofish install helm
```

1) Setup ‘tiller’

https://helm.sh/docs/using_helm/#tiller-and-role-based-access-control

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
