#! /bin/sh

PYVER="python3.7"
set -ex

ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime
echo "$TZ" >/etc/timezone

# Add Python backport ppa
apt-get update
apt-get install -y software-properties-common
add-apt-repository -y ppa:deadsnakes/ppa

# Install tools
apt-get update
apt-get install -y \
    bison \
    build-essential \
    cmake \
    file \
    flex \
    gawk \
    git \
    mingw-w64 \
    m4 \
    ninja-build \
    "$PYVER" \
    rsync \
    sudo \
    texinfo \
    wget \
    zip \
    zlib1g-dev
rm -rf /var/lib/apt/lists/*

update-alternatives --install /usr/bin/python3 python3 /usr/bin/"$PYVER" 0

wget https://bootstrap.pypa.io/get-pip.py
python3 get-pip.py
rm get-pip.py

