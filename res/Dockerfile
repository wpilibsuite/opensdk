# Requires docker 17.05 or newer.
# For installation, see https://docs.docker.com/install/linux/docker-ce/ubuntu/
ARG BASE
FROM docker.io/ubuntu:${BASE}

RUN apt-get update && apt-get install -y \
    bison \
    build-essential \
    cmake \
    file \
    flex \
    gawk \
    mingw-w64 \
    m4 \
    ninja-build \
    rsync \
    sudo \
    texinfo \
    wget \
    zip \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build
