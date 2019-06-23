#!/bin/bash
# Define key infos
NODE_TAG=8.16.0-stretch
CUDA=10.1
SHINOBI_DATE=${1}
SHINOBI_HASH_LONG=${2}
SHINOBI_HASH_SHORT=`echo ${SHINOBI_HASH_LONG} | cut -c 1-8`
SHINOBI_TAG=${SHINOBI_DATE}_${SHINOBI_HASH_SHORT}
# Define directories
PROJECT_ROOT=$(pwd)
WORKDIR=${PROJECT_ROOT}/${SHINOBI_TAG}

# Create the workdir
mkdir -p ${WORKDIR}

# Create Dockerfile
cat << EOF > ${WORKDIR}/Dockerfile
FROM nvidia/cuda:10.1-base-ubuntu18.04
MAINTAINER Neatori Kawashiro

# SET NVIDIA driver libraries required at runtime
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES video,compute,utility

# INSTALL Dependancies
RUN \
  apt update && \
  apt install -y build-essential curl ffmpeg x264 x265 \
    cuda-command-line-tools-${CUDA/./-} \
#    cuda-cublas-${CUDA/./-} \
    cuda-cufft-${CUDA/./-} \
    cuda-curand-${CUDA/./-} \
    cuda-cusolver-${CUDA/./-} \
    cuda-cusparse-${CUDA/./-} \
#    cuda-samples-${CUDA/./-} && \
  rm -rf /var/lib/apt/lists/*

# SET node.js 8 source
RUN \
  curl -sL https://deb.nodesource.com/setup_8.x | bash -

# INSTALL node.js 8
RUN \
  apt update && \
    apt install -y nodejs

# BUILD NVIDIA samples for debugging
#RUN \
#  ./usr/local/cuda-${CUDA/./-}/samples/make

# INSTALL Shinobi
RUN mkdir -p /opt/shinobi
RUN mkdir -p /etc/shinobi
WORKDIR /opt/shinobi
RUN \
  curl -SL https://gitlab.com/Shinobi-Systems/Shinobi/-/archive/${SHINOBI_HASH_LONG}/Shinobi-${SHINOBI_HASH_LONG}.tar.gz \
  | tar xz -C . --strip-components=1
RUN npm install

# EXPOSE port, config, and videos
EXPOSE 8080
VOLUME ["/etc/shinobi/config"]
VOLUME ["/opt/shinobi/videos"]

# HOOK the runtime configuration script
COPY ./entrypoint.sh /opt/shinobi
RUN chmod +x /opt/shinobi/entrypoint.sh
ENTRYPOINT ["/opt/shinobi/entrypoint.sh"]
CMD ["node", "camera.js"]
EOF

# Copy the entrypoint.sh
cp ${PROJECT_ROOT}/entrypoint.sh ${WORKDIR}/entrypoint.sh

# Run Docker build
cd ${WORKDIR}
docker build -t neatori18/shinobi:${SHINOBI_TAG} .
cd ${PROJECT_ROOT}

# Push the image to the registory
#docker push neatori18/shinobi:${SHINOBI_TAG}
