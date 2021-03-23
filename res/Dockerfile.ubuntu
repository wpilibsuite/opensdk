# Requires docker 17.05 or newer.
# For installation, see https://docs.docker.com/install/linux/docker-ce/ubuntu/
ARG BASE
FROM docker.io/ubuntu:${BASE} as coreutils
ARG BASE
ARG VER=8.32
ARG KEY=6C37DC12121A5006BC1DB804DF6FD971306037D9

RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    && rm -rf /var/lib/apt/lists/* \
    && gpg --keyserver "keyserver.ubuntu.com" --recv-key "${KEY}" 

RUN wget "https://ftp.gnu.org/gnu/coreutils/coreutils-${VER}.tar.xz" \
    && wget "https://ftp.gnu.org/gnu/coreutils/coreutils-${VER}.tar.xz.sig" \
    && gpg --verify "coreutils-${VER}.tar.xz.sig" \
    && tar xf "coreutils-${VER}.tar.xz" && cd "coreutils-${VER}" \
    && mkdir "./build" && cd "./build" \
    && FORCE_UNSAFE_CONFIGURE=1 ../configure \
    --prefix=/opt/coreutils/ \
    --libexecdir=/opt/coreutils/lib/ \
    --enable-no-install-program=groups,hostname,kill,uptime \
    && make -j5 && make install \
    && cd "../../" && rm -r "coreutils-${VER}"*

FROM docker.io/ubuntu:${BASE} as binutils
ARG BASE
ARG VER=2.36
ARG KEY=3A24BC1E8FB409FA9F14371813FCEF89DD9E3C4F

RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    && rm -rf /var/lib/apt/lists/* \
    && gpg --keyserver "keyserver.ubuntu.com" --recv-key "${KEY}" 

RUN wget "https://ftp.gnu.org/gnu/binutils/binutils-${VER}.tar.xz" \
    && wget "https://ftp.gnu.org/gnu/binutils/binutils-${VER}.tar.xz.sig" \
    && gpg --verify "binutils-${VER}.tar.xz.sig" \
    && tar xf "binutils-${VER}.tar.xz" && cd "binutils-${VER}" \
    && mkdir "./build" && cd "./build" \
    && FORCE_UNSAFE_CONFIGURE=1 ../configure \
    --prefix=/opt/binutils/ \
    --libexecdir=/opt/binutils/lib/ \
    && make -j5 && make install \
    && cd "../../" && rm -r "binutils-${VER}"*

FROM docker.io/ubuntu:${BASE}
ARG BASE

RUN apt-get update && apt-get install -y \
    bison \
    build-essential \
    file \
    flex \
    gawk \
    libgmp-dev libmpfr-dev libmpc-dev \
    mingw-w64 \
    m4 \
    rsync \
    sudo \
    texinfo \
    wget \
    zip \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

COPY --from=coreutils /opt/coreutils /opt/coreutils
COPY --from=binutils /opt/binutils /opt/binutils
ENV PATH="/opt/coreutils/bin/:/opt/binutils/bin/:$PATH"

WORKDIR /build
