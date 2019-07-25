ARG BUILD_FROM
#FROM $BUILD_FROM
FROM alpine:3.10.1

# Install base
RUN \
    apk add --no-cache \
    openssl \
    libffi \
    musl \
    git \
    socat \
    glib \
    libstdc++ \
    eudev \
    eudev-libs \
    py3-setuptools \
    bash \
    vim

ARG BUILD_ARCH
ENV BUILD_ARCH=amd64
WORKDIR /usr/src

# Install requirements
COPY requirements.txt .
RUN export MAKEFLAGS="-j$(nproc)" \
    && pip3 install --no-cache-dir --no-index --only-binary=:all: --find-links \
        "https://wheels.home-assistant.io/alpine-$(cut -d '.' -f 1-2 < /etc/alpine-release)/${BUILD_ARCH}/" \
        -r ./requirements.txt \
    && rm -f requirements.txt

# Install HassIO
COPY . hassio
RUN pip3 install --no-cache-dir -e ./hassio \
    && python3 -m compileall ./hassio/hassio

# Initialize udev daemon, handle CMD
COPY entry.sh /bin/
ENTRYPOINT ["/bin/entry.sh"]

# Copy script to setup iptables to make hassio think it's configured

WORKDIR /usr/src/hassio

CMD [ "python3", "-m", "hassio" ]
