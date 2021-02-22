# Requires docker 17.05 or newer.
# For installation, see https://docs.docker.com/install/linux/docker-ce/ubuntu/
ARG BASE
FROM docker.io/ubuntu:${BASE}
ARG BASE

RUN apt-get update && apt-get install -y tzdata && apt-get install -y \
    autoconf \
    automake \
    autotools-dev \
    bc \
    binutils-dev \
    bison \
    build-essential \
    chrpath \
    cmake \
    debhelper \
    dejagnu \
    devscripts \
    docbook-xml \
    docbook-xsl \
    expat \
    file \
    flex \
    g++ \
    g++-mingw-w64 \
    g++-multilib \
    gawk \
    gcc \
    gcc-multilib \
    gdb \
    gettext \
    gperf \
    libbz2-dev \
    libc6-dev \
    libcap-dev \
    libcloog-isl-dev \
    libexpat1-dev \
    libgcc1 \
    libgmp-dev \
    liblzma-dev \
    libmpc-dev \
    libmpfr-dev \
    libncurses5-dev \
    libtool \
    libreadline-dev \
    lintian \
    make \
    ncurses-dev \
    patch \
    pkg-config \
    python-all-dev \
    quilt \
    $([ "${BASE}" = "14.04" ] && echo "realpath" ) \
    rsync \
    subversion \
    sudo \
    texinfo \
    wget \
    xsltproc \
    xz-utils \
    zip \
    zlib1g-dev \
    zsh \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /build
