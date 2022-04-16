#! /bin/sh

set -ex

DISTRO="$(grep 'DISTRIB_CODENAME' /etc/lsb-release | sed 's/.*=//g')"
SOURCES="main universe"
MAIN_REPO="http://us.archive.ubuntu.com/ubuntu/"
PORT_REPO="http://us.ports.ubuntu.com/ubuntu-ports/"

cat << EOF > /etc/apt/sources.list
deb [arch=amd64,i386] ${MAIN_REPO} ${DISTRO} ${SOURCES}
deb [arch=amd64,i386] ${MAIN_REPO} ${DISTRO}-security ${SOURCES}
deb [arch=amd64,i386] ${MAIN_REPO} ${DISTRO}-updates ${SOURCES}

deb [arch=arm64,armhf] ${PORT_REPO} ${DISTRO} ${SOURCES}
deb [arch=arm64,armhf] ${PORT_REPO} ${DISTRO}-security ${SOURCES}
deb [arch=arm64,armhf] ${PORT_REPO} ${DISTRO}-updates ${SOURCES}
EOF

dpkg --add-architecture i386
dpkg --add-architecture arm64
dpkg --add-architecture armhf

ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime
echo "$TZ" >/etc/timezone

# Add Python backport ppa
apt-get update

# Install tools
apt-get update
apt-get install -y \
    bison \
    build-essential \
    cmake \
    crossbuild-essential-armhf \
    crossbuild-essential-arm64 \
    file \
    flex \
    gawk \
    gcc-i686-linux-gnu \
    g++-i686-linux-gnu \
    git \
    libgmp-dev \
    libmpfr-dev \
    libmpc-dev \
    libisl-dev \
    mingw-w64 \
    m4 \
    python3 \
    python3-pip \
    rsync \
    sudo \
    texinfo \
    wget \
    zip \
    zlib1g-dev:i386 \
    zlib1g-dev:amd64 \
    zlib1g-dev:armhf \
    zlib1g-dev:arm64

apt-get autoclean
rm -rf /var/lib/apt/lists/*

