FROM nvidia/cuda:10.1-devel-ubuntu18.04
MAINTAINER Neatori Kawashiro

# SET NVIDIA driver libraries required at runtime
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES video,compute,utility

# INSTALL Dependancies
RUN   apt update &&   apt install -y build-essential xz-utils vim sed curl wget software-properties-common x264 x265     cuda-command-line-tools-10-1 #    cuda-cublas-10-1     cuda-cufft-10-1     cuda-curand-10-1     cuda-cusolver-10-1     cuda-cusparse-10-1 #    cuda-samples-10-1 &&   rm -rf /var/lib/apt/lists/*

# Install ffmpeg from source
RUN   apt update -qq && apt install -y     autoconf     automake     cmake     git-core     nasm     cuda-npp-dev-10-1     libass-dev     libfdk-aac-dev     libmp3lame-dev     libnuma-dev     libopus-dev     libsdl2-dev     libtool     libvorbis-dev     libvpx-dev     libx264-dev     libx265-dev     pkg-config     texinfo     zlib1g-dev

WORKDIR /usr/local/share

# Install webm from source
RUN git clone https://chromium.googlesource.com/webm/libvpx
RUN cd libvpx &&     PATH="/bin:/usr/clearos/bin:/usr/clearos/bin:/usr/clearos/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin:/root/bin" ./configure       --prefix="/root/ffmpeg_build"       --disable-examples       --enable-runtime-cpu-detect       --enable-vp9       --enable-vp8       --enable-postproc       --enable-vp9-postproc       --enable-multi-res-encoding       --enable-webm-io       --enable-better-hw-compatibility       --enable-vp9-highbitdepth       --enable-onthefly-bitpacking       --enable-realtime-only       --cpu=native       --as=nasm &&       PATH="/bin:/usr/clearos/bin:/usr/clearos/bin:/usr/clearos/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin:/root/bin" make -j32 &&       make -j32 install &&       make -j32 clean

# Install NVIDIA codec headers
RUN git clone https://git.videolan.org/git/ffmpeg/nv-codec-headers.git
RUN cd nv-codec-headers &&     make && make install

# Install FFMPEG from source
RUN wget https://ffmpeg.org/releases/ffmpeg-4.1.3.tar.xz -O ffmpeg-release-64bit-static.tar.xz
#RUN wget https://johnvansickle.com/ffmpeg/git-source/ffmpeg-git.tar.xz -O ffmpeg-release-64bit-static.tar.xz

RUN tar xvfJ ffmpeg-release-64bit-static.tar.xz &&     cd ffmpeg-4.1.3* &&     PATH="/bin:/usr/local/cuda-10.1/bin/:/usr/clearos/bin:/usr/clearos/bin:/usr/clearos/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin:/root/bin" PKG_CONFIG_PATH="/root/ffmpeg_build/lib/pkgconfig" ./configure       --prefix="/root/ffmpeg_build"       --pkg-config-flags="--static"       --extra-cflags="-I/root/ffmpeg_build/include -I/usr/local/cuda/include"       --extra-ldflags="-L/root/ffmpeg_build/lib -L/usr/local/cuda/lib64"       --extra-libs="-lpthread -lm"       --bindir="/root/bin"       --enable-cuda       --enable-cuda-sdk       --enable-cuvid       --enable-gpl       --enable-libass       --enable-libfdk-aac       --enable-libfreetype       --enable-libmp3lame       --enable-libnpp       --enable-libopus       --enable-libvorbis       --enable-libvpx       --enable-libx264       --enable-libx265       --enable-nonfree       --enable-nvenc &&     PATH="/bin:/usr/local/cuda-10.1/bin/:/usr/clearos/bin:/usr/clearos/bin:/usr/clearos/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin:/root/bin" make -j32 &&     make -j32 install &&     hash -r

RUN rm -f ffmpeg-release-64bit-static.tar.xz     && rm -rf ./ffmpeg-4.1.3

RUN   apt remove     cmake     git-core     nasm     pkgconf     cuda-npp-dev-10-1     libass-dev     libfdk-aac-dev     libfreetype6-dev     libmp3lame-dev     libnuma-dev     libopus-dev     libsdl2-dev     libtool     libvorbis-dev     libvpx-dev     libx264-dev     libx265-dev     pkg-config     texinfo     xz-utils     zlib1g-dev --purge -y

# SET node.js 8 source
RUN   curl -sL https://deb.nodesource.com/setup_9.x | bash -

# INSTALL node.js 8
RUN   apt update &&     apt install -y nodejs

# BUILD NVIDIA samples for debugging
#RUN #  ./usr/local/cuda-10-1/samples/make

RUN mkdir -p /opt/shinobi
RUN mkdir -p /etc/shinobi
# Copy compiled ffmpeg to replace Shinobi ffmpeg executable
RUN mkdir /opt/shinobi/ffmpeg &&     mv /root/bin/ffmpeg /opt/shinobi/ffmpeg/ &&     mv /root/bin/ffprobe /opt/shinobi/ffmpeg/

# INSTALL Shinobi
WORKDIR /opt/shinobi
RUN   curl -SL https://gitlab.com/Shinobi-Systems/Shinobi/-/archive/840f4953db08ef650a743171b429830b6b1a0529/Shinobi-840f4953db08ef650a743171b429830b6b1a0529.tar.gz   | tar xz -C . --strip-components=1

# Install NodeJS dependencies
RUN npm i npm@latest -g
RUN npm install pm2 -g
RUN npm install
RUN npm install ffbinaries

# EXPOSE port, config, and videos
EXPOSE 8080
VOLUME ["/etc/shinobi/config"]
VOLUME ["/opt/shinobi/videos"]

RUN sed -i '$ s/.$//' /etc/environment &&     truncate -s -1 /etc/environment &&     echo -n ':/opt/shinobi/ffmpeg"' >> /etc/environment

# HOOK the runtime configuration script
COPY ./files/entrypoint.sh /opt/shinobi
COPY ./files/pm2Shinobi.yml /opt/shinobi
RUN chmod +x /opt/shinobi/entrypoint.sh
ENTRYPOINT ["/opt/shinobi/entrypoint.sh"]
CMD ["node", "camera.js"]
