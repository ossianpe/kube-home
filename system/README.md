# Install `Kubernetes` with `NVIDIA` cpu

## Setup
In order to setup a new `kubernetes` instance instance, please follow the order listed below:

1) Install [docker-ce](INSTALL-DOCKER-CE.md)

1) Install [NVIDIA docker runtime](INSTALL-NVIDIA-DOCKER-RUNTIME.md)

1) Install [kubeadm](INSTALL-KUBEADM.md) and `kubernetes` cluster

### Alternative setup
If `NVIDIA` gpu is not needed, omit step 2, so only install:

1) Install [docker-ce](INSTALL-DOCKER-CE.md)

1) Install [kubeadm](INSTALL-KUBEADM.md) and `kubernetes` cluster
