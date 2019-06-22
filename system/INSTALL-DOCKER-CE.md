# Installing `docker-ce`
## Setup
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

1) Enable `docker-ce` to start a system boot

```
sudo systemctl enable docker
```

1) Start `docker-ce`

```
sudo systemctl start docker
```

## Update `docker-ce` system control driver
For `kubeadm` to work (especially with `NVIDIA` gpu support) we will need to change `docker-ce`'s cgroup driver to systemd. 

_Please note, there may be some issues with using `systemd` opposed to `cgroup` at this point with `docker-ce`. May need to investigate this later._

To do this:

1) Update `docker-ce` service definition

```
vi /usr/lib/systemd/system/docker.service
```

Append `--exec-opt native.cgroupdriver=systemd` to the line defining `ExecStart`

For example, in my case it became:

```
ExecStart=/usr/bin/dockerd -H fd:// \
   --containerd=/run/containerd/containerd.sock \
   --exec-opt native.cgroupdriver=systemd
```

1) Restart docker

```
systemctl restart docker
```
