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

#### Patch driver for unlimited NVENC transcodes
Apply this patch to remove the two stream transcode limit in the `NVIDIA` driver

_Note: this is confirmed working with `NVIDIA` driver version `418.67`. Other versions may not work._

1) Clone `nvidia-patch`

```
git clone https://github.com/keylase/nvidia-patch
```

1) Run patch

```
cd nvidia-patch && ./patch.sh
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

1) Set default runtime to `nvidia`

    Open file `/etc/docker/daemon.json`

    Add the line `"default-runtime": "nvidia"` to the json file, so it looks something like the following:

```
{
    "default-runtime": "nvidia",
    "runtimes": {
        "nvidia": {
            "path": "/usr/bin/nvidia-container-runtime",
            "runtimeArgs": []
        }
    }
}
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

##### Additional validation
To validate even further, please follow [this article](https://xcat-docs.readthedocs.io/en/stable/advanced/gpu/nvidia/verify_cuda_install.html).

# References

### Installing `NVIDIA` drivers for `Kubernetes`
https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#pre-installation-actions

### Install NVIDIA Container Runtime for Docker 2
https://nvidia.github.io/nvidia-docker/

https://docs.nvidia.com/datacenter/kubernetes/kubernetes-install-guide/index.html#kubernetes-ncrd-install-container-runtime (this is only for Ubuntu..)

### Set docker runtime to `nvidia`
https://docs.deep-hybrid-datacloud.eu/en/latest/technical/kubernetes/gpu-kubernetes-ubuntu.html
