Kubernetes kubeadm setup:
https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/

For flannel, make sure to run:

kubeadm init -—pod-network-cidr=10.244.0.0/16

Deploying Helm:

Follow setup guide found at:

Setup ‘tiller’ user at:
https://helm.sh/docs/using_helm/#tiller-and-role-based-access-control

Troubleshooting:
https://medium.com/@pczarkowski/easily-install-uninstall-helm-on-rbac-kubernetes-8c3c0e22d0d7

Deploying metallb:

In order to ensure that layer 2 is setup. Follow this guide:
https://metallb.universe.tf/tutorial/layer2/

When asked to create ‘example-layer2-config.yaml’ use the following instead:

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
