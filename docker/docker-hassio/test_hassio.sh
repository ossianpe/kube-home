docker rm hassio_supervisor
    docker run --name hassio_supervisor \
        --privileged \
        --security-opt apparmor:unconfined \
        --security-opt seccomp=unconfined \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v /var/run/dbus:/var/run/dbus \
        -v /mnt/home-assistant/hassio:/data \
        -e SUPERVISOR_SHARE=/mnt/home-assistant/hassio \
        -e SUPERVISOR_NAME=hassio_supervisor \
        -e HOMEASSISTANT_REPOSITORY=homeassistant/x86_64-homeassistant \
        hassio:0724
