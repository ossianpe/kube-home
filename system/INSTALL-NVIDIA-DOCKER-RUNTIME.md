# NVIDIA graphics runtime for `docker-ce` setup:
This guide describes how to setup NVIDIA graphics for `docker-ce`

## Setup
The following must be installed/configured:

* [`docker-ce`](INSTALL-DOCKER-CE.md)
* `NVIDIA Drivers`
* `NVIDIA Container Runtime for Docker 2`

#### Installing NVIDIA Drivers
Several steps must be performed before installing drivers

1) Install `gcc`

```
yum install gcc
```

1) Install kernel headers and development packages

```
sudo yum install kernel-devel-$(uname -r) kernel-headers-$(uname -r)
```

1) Download NVIDIA CUDA driver

_Please note, be sure to install latest version found [here](https://developer.nvidia.com/cuda-downloads?target_os=Linux&target_arch=x86_64&target_distro=RHEL&target_version=7&target_type=rpmlocal)

```
curl -LO https://developer.nvidia.com/compute/cuda/10.1/Prod/local_installers/cuda-repo-rhel7-10-1-local-10.1.168-418.67-1.0-1.x86_64.rpm
```

1) Install repository metadata

```
sudo rpm -i cuda-repo-rhel7-10-1-local-10.1.168-418.67-1.0-1.x86_64.rpm
```

1) Install NVIDIA CUDA driver

```
sudo yum install cuda
```

1) Additionally, `PATH` may need to be set

```
export PATH=/usr/local/cuda-10.1/bin:/usr/local/cuda-10.1/NsightCompute-2019.1${PATH:+:${PATH}}
```

#### Install NVIDIA Container Runtime for Docker 2

1) Download offical GPG keys

```
#curl -s -L https://nvidia.github.io/nvidia-container-runtime/centos7/nvidia-container-runtime.repo | \
  sudo tee /etc/yum.repos.d/nvidia-container-runtime.repo
curl -s -L https://nvidia.github.io/nvidia-docker/centos7/nvidia-docker.repo | \
  sudo tee /etc/yum.repos.d/nvidia-docker.repo
```

1) Install NVIDIA Container Runtime

```
sudo yum install nvidia-docker2
```

1) Restart the system

```
sudo shutdown -r now
```

#### Validate driver installation
To ensure that the drivers have been installed successfully run

```
docker run -it --rm --runtime nvidia nvidia/cuda nvidia-smi
```

# References

### Installing `NVIDIA` drivers for `Kubernetes`
https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#pre-installation-actions

### Install NVIDIA Container Runtime for Docker 2
https://nvidia.github.io/nvidia-docker/
https://docs.nvidia.com/datacenter/kubernetes/kubernetes-install-guide/index.html#kubernetes-ncrd-install-container-runtime (this is only for Ubuntu..)
