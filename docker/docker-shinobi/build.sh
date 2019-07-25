#!/bin/bash
# Define key infos
CUDA=10.1
CUDA_SDK="${CUDA}.168-418.67_1.0-1"
SHINOBI_DATE=${1}
SHINOBI_HASH_LONG=${2}
SHINOBI_HASH_SHORT=`echo ${SHINOBI_HASH_LONG} | cut -c 1-8`
SHINOBI_TAG=${SHINOBI_DATE}_${SHINOBI_HASH_SHORT}
# Define directories
PROJECT_ROOT=$(pwd)
WORKDIR=${PROJECT_ROOT}/${SHINOBI_TAG}

# Set FFMPEG version
FFMPEG_VERSION=4.1.3

# Create the workdir
mkdir -p ${WORKDIR}

# Create Dockerfile
cat << EOF > ${WORKDIR}/Dockerfile
FROM nvidia/cuda:10.1-devel-ubuntu18.04
MAINTAINER Neatori Kawashiro

# SET NVIDIA driver libraries required at runtime
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES video,compute,utility

# INSTALL Dependancies
RUN \
  apt update && \
  apt install -y build-essential xz-utils vim sed curl wget software-properties-common x264 x265 \
    cuda-command-line-tools-${CUDA/./-} \
#    cuda-cublas-${CUDA/./-} \
    cuda-cufft-${CUDA/./-} \
    cuda-curand-${CUDA/./-} \
    cuda-cusolver-${CUDA/./-} \
    cuda-cusparse-${CUDA/./-} \
#    cuda-samples-${CUDA/./-} && \
  rm -rf /var/lib/apt/lists/*

# Install ffmpeg from source
RUN \
  apt update -qq && apt install -y \
    autoconf \
    automake \
    cmake \
    git-core \
    nasm \
    cuda-npp-dev-10-1 \
    libass-dev \
    libfdk-aac-dev \
    libmp3lame-dev \
    libnuma-dev \
    libopus-dev \
    libsdl2-dev \
    libtool \
    libvorbis-dev \
    libvpx-dev \
    libx264-dev \
    libx265-dev \
    pkg-config \
    texinfo \
    zlib1g-dev

WORKDIR /usr/local/share

# Install webm from source
RUN git clone https://chromium.googlesource.com/webm/libvpx
RUN cd libvpx && \
    PATH="/bin:$PATH" ./configure \
      --prefix="$HOME/ffmpeg_build" \
      --disable-examples \
      --enable-runtime-cpu-detect \
      --enable-vp9 \
      --enable-vp8 \
      --enable-postproc \
      --enable-vp9-postproc \
      --enable-multi-res-encoding \
      --enable-webm-io \
      --enable-better-hw-compatibility \
      --enable-vp9-highbitdepth \
      --enable-onthefly-bitpacking \
      --enable-realtime-only \
      --cpu=native \
      --as=nasm && \
      PATH="/bin:$PATH" make -j$(nproc) && \
      make -j$(nproc) install && \
      make -j$(nproc) clean

# Install NVIDIA codec headers
RUN git clone https://git.videolan.org/git/ffmpeg/nv-codec-headers.git
RUN cd nv-codec-headers && \
    make && make install

# Install FFMPEG from source
RUN wget https://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.xz -O ffmpeg-release-64bit-static.tar.xz
#RUN wget https://johnvansickle.com/ffmpeg/git-source/ffmpeg-git.tar.xz -O ffmpeg-release-64bit-static.tar.xz

RUN tar xvfJ ffmpeg-release-64bit-static.tar.xz && \
    cd ffmpeg-${FFMPEG_VERSION}* && \
    PATH="/bin:/usr/local/cuda-${CUDA}/bin/:$PATH" PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure \
      --prefix="$HOME/ffmpeg_build" \
      --pkg-config-flags="--static" \
      --extra-cflags="-I$HOME/ffmpeg_build/include -I/usr/local/cuda/include" \
      --extra-ldflags="-L$HOME/ffmpeg_build/lib -L/usr/local/cuda/lib64" \
      --extra-libs="-lpthread -lm" \
      --bindir="$HOME/bin" \
      --enable-cuda \
      --enable-cuda-sdk \
      --enable-cuvid \
      --enable-gpl \
      --enable-libass \
      --enable-libfdk-aac \
      --enable-libfreetype \
      --enable-libmp3lame \
      --enable-libnpp \
      --enable-libopus \
      --enable-libvorbis \
      --enable-libvpx \
      --enable-libx264 \
      --enable-libx265 \
      --enable-nonfree \
      --enable-nvenc && \
    PATH="/bin:/usr/local/cuda-${CUDA}/bin/:$PATH" make -j$(nproc) && \
    make -j$(nproc) install && \
    hash -r

RUN rm -f ffmpeg-release-64bit-static.tar.xz \
    && rm -rf ./ffmpeg-4.1.3

RUN \
  apt remove \
    cmake \
    git-core \
    nasm \
    pkgconf \
    cuda-npp-dev-10-1 \
    libass-dev \
    libfdk-aac-dev \
    libfreetype6-dev \
    libmp3lame-dev \
    libnuma-dev \
    libopus-dev \
    libsdl2-dev \
    libtool \
    libvorbis-dev \
    libvpx-dev \
    libx264-dev \
    libx265-dev \
    pkg-config \
    texinfo \
    xz-utils \
    zlib1g-dev --purge -y

# SET node.js 8 source
RUN \
  curl -sL https://deb.nodesource.com/setup_9.x | bash -

# INSTALL node.js 8
RUN \
  apt update && \
    apt install -y nodejs

# BUILD NVIDIA samples for debugging
#RUN \
#  ./usr/local/cuda-${CUDA/./-}/samples/make

RUN mkdir -p /opt/shinobi
RUN mkdir -p /etc/shinobi
# Copy compiled ffmpeg to replace Shinobi ffmpeg executable
RUN mkdir /opt/shinobi/ffmpeg && \
    mv /root/bin/ffmpeg /opt/shinobi/ffmpeg/ && \
    mv /root/bin/ffprobe /opt/shinobi/ffmpeg/

# INSTALL Shinobi
WORKDIR /opt/shinobi
RUN \
  curl -SL https://gitlab.com/Shinobi-Systems/Shinobi/-/archive/${SHINOBI_HASH_LONG}/Shinobi-${SHINOBI_HASH_LONG}.tar.gz \
  | tar xz -C . --strip-components=1

# Install NodeJS dependencies
RUN npm i npm@latest -g
RUN npm install pm2 -g
RUN npm install
RUN npm install ffbinaries

# EXPOSE port, config, and videos
EXPOSE 8080
VOLUME ["/etc/shinobi/config"]
VOLUME ["/opt/shinobi/videos"]

RUN sed -i '$ s/.$//' /etc/environment && \
    truncate -s -1 /etc/environment && \
    echo -n ':/opt/shinobi/ffmpeg"' >> /etc/environment

# HOOK the runtime configuration script
COPY ./files/entrypoint.sh /opt/shinobi
COPY ./files/pm2Shinobi.yml /opt/shinobi
RUN chmod +x /opt/shinobi/entrypoint.sh
ENTRYPOINT ["/opt/shinobi/entrypoint.sh"]
CMD ["node", "camera.js"]
EOF

# Copy the additional files
cp -r ${PROJECT_ROOT}/files ${WORKDIR}/files

# Run Docker build
cd ${WORKDIR}
docker build -t neatori18/shinobi:${SHINOBI_TAG} .
cd ${PROJECT_ROOT}

# Push the image to the registory
#docker push neatori18/shinobi:${SHINOBI_TAG}
