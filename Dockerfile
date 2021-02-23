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

COPY --from=coreutils /opt/coreutils /opt/coreutils
ENV PATH="/opt/coreutils/bin/:$PATH"

WORKDIR /build
