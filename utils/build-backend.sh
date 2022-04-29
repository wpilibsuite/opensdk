#! /usr/bin/env bash
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

# Change directory to project base
cd "$(dirname "$0")/.." || exit

export BUILD_BACKEND=true

set -a
ROOT_DIR="${PWD}"
# shellcheck source=../scripts/setup.sh
source "$ROOT_DIR/scripts/setup.sh"
set +a

die() {
    echo "[FATAL]: $1" >&2
    exit 1
}

# Check if system is a Linux x86_64 system
if [ "$(uname)" != "Linux" ] || [ "$(uname -m)" != "x86_64" ]; then
    die "Backend builds require a x86_64 Linux system"
fi

# Set callback on error
function onexit() {
    local -r code="$?"
    echo "[ERROR]: Exiting with code ${code}"
}
trap onexit "err"

mkdir -p "${BUILD_DIR}"
MAKE="make -C ${ROOT_DIR}/makes/ --no-print-directory"

${MAKE} \
    task/10-sysroot \
    task/11-sources \
    task/12-patches \
    task/13-normalize \
    task/30-binutils \
    task/40-gcc-configure \
    task/41-gcc-frontend \
    task/42-gcc-backend \
    task/98-package-backend

mkdir -p "${OUTPUT_DIR}"
cp "${BUILD_DIR}/${TARGET_TUPLE}.tar" \
    "${OUTPUT_DIR}/" 

