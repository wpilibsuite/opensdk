#! /bin/sh

PYVER="python3.7"
set -ex

DISTRO="$(grep 'DISTRIB_CODENAME' /etc/lsb-release | sed 's/.*=//g')"
SOURCES="main restricted universe multiverse"
MAIN_REPO="http://us.archive.ubuntu.com/ubuntu/"
PORT_REPO="http://us.ports.ubuntu.com/ubuntu-ports/"

cat << EOF > /etc/apt/sources.list
deb [arch=amd64] ${MAIN_REPO} ${DISTRO} ${SOURCES}
deb [arch=amd64] ${MAIN_REPO} ${DISTRO}-security ${SOURCES}
deb [arch=amd64] ${MAIN_REPO} ${DISTRO}-updates ${SOURCES}

deb [arch=arm64,armhf] ${PORT_REPO} ${DISTRO} ${SOURCES}
deb [arch=arm64,armhf] ${PORT_REPO} ${DISTRO}-security ${SOURCES}
deb [arch=arm64,armhf] ${PORT_REPO} ${DISTRO}-updates ${SOURCES}
EOF

ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime
echo "$TZ" >/etc/timezone

# Add Python backport ppa
dpkg --add-architecture arm64
dpkg --add-architecture armhf
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
    git \
    mingw-w64 \
    m4 \
    ninja-build \
    rsync \
    software-properties-common \
    sudo \
    texinfo \
    wget \
    zip \
    zlib1g-dev:amd64 \
    zlib1g-dev:armhf \
    zlib1g-dev:arm64

# Install python3.7
add-apt-repository -y ppa:deadsnakes/ppa
apt-get update
apt-get install -y "$PYVER"
update-alternatives --install /usr/bin/python3 python3 /usr/bin/"$PYVER" 0

# Setup pip with python3.7
wget https://bootstrap.pypa.io/get-pip.py
python3 get-pip.py
rm get-pip.py

apt-get autoclean
rm -rf /var/lib/apt/lists/*

