#! /usr/bin/bash

# Copyright 2021-2022 Ryan Hirasaki
#
# This file is part of OpenSDK
#
# OpenSDK is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# OpenSDK is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with OpenSDK; see the file COPYING. If not see
# <http://www.gnu.org/licenses/>.

# shellcheck disable=SC2010

FUNC_ONLY=true

# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh"

function download_or_die() {
    wget -nc -nv "$1" &>/dev/null ||
        die "Failed to download archive from $1"
}

function download_extract() {
    download_or_die "$1"
    tar -xf "${1/*\//}" || die "${1/*\//} extract failed"
}

rm -rf "${DOWNLOAD_DIR}"
mkdir -p "${DOWNLOAD_DIR}"

xpushd "${DOWNLOAD_DIR}"
GNU_MIRROR="https://ftpmirror.gnu.org/gnu"
GCC_INFRA_MIRROR="https://gcc.gnu.org/pub/gcc/infrastructure"
EXPAT_MIRROR="https://github.com/libexpat/libexpat/releases/download"
SAVANNAH_MIRROR="https://git.savannah.gnu.org/cgit/config.git/plain"
download_extract "${GNU_MIRROR}/binutils/binutils-${V_BIN}.tar.gz"
download_extract "${GNU_MIRROR}/gcc/gcc-${V_GCC}/gcc-${V_GCC}.tar.gz"
download_extract "${GNU_MIRROR}/gdb/gdb-${V_GDB}.tar.gz"
download_extract "${GNU_MIRROR}/make/make-${V_MAKE}.tar.gz"
download_extract "${EXPAT_MIRROR}/R_${V_EXPAT//./_}/expat-${V_EXPAT}.tar.gz"
download_extract "${GCC_INFRA_MIRROR}/gmp-${V_GMP}.tar.bz2"
download_or_die "${SAVANNAH_MIRROR}/config.guess"
download_or_die "${SAVANNAH_MIRROR}/config.sub"

xpushd "gcc-${V_GCC}"
# Use HTTPS from the GNU mirrors
for proto in ftp http; do
    sed -i'' -e "s/${proto}:\/\//https:\/\//g" ./contrib/download_prerequisites
done
./contrib/download_prerequisites || die "gcc prerequisite fetching failed"
xpopd

for p in \
    "binutils-${V_BIN}" \
    "expat-${V_EXPAT}" \
    "gcc-${V_GCC}" \
    "gdb-${V_GDB}" \
    "gmp-${V_GMP}" \
    "make-${V_MAKE}"; do
    for f in config.guess config.sub; do
        find "$p" -mindepth 2 -name "$f" -exec chmod +w '{}' ';'
        find "$p" -mindepth 2 -name "$f" -exec cp -v "$f" '{}' ';'
    done
done

xpopd
