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

1) Enable `docker-ce` to start a system boot

```
sudo systemctl enable docker
```

1) Start `docker-ce`

```
sudo systemctl start docker
```
