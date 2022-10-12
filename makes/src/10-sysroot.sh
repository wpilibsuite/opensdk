#! /usr/bin/bash

# Copyright 2021-2023 Ryan Hirasaki
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

set -e
FUNC_ONLY=true

# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh"

rm -rf "${BUILD_DIR}/sysroot-build"
rm -rf "${BUILD_DIR}/sysroot-install"
mkdir "${BUILD_DIR}/sysroot-build"
mkdir -p "${BUILD_DIR}/sysroot-install/${TARGET_TUPLE}/sysroot"

ARGS=(
    "${TARGET_DISTRO}"
    "${TARGET_PORT}"
    "${TARGET_DISTRO_RELEASE}"
)
if [ "$TARGET_LIB_REBUILD" ]; then
    ARGS+=("--minimal-toolchain")
fi

xpushd "${BUILD_DIR}/sysroot-build"
python3 -m pip install -U "${ROOT_DIR}/res/opensysroot"
python3 -m opensysroot \
    "${ARGS[@]}" \
    . || die "opensysroot failed"
SYSROOT_DIR="${PWD}/${TARGET_DISTRO}/${TARGET_DISTRO_RELEASE}/${TARGET_PORT}"
if ! [ "$TARGET_LIB_REBUILD" ]; then
    xpushd "${SYSROOT_DIR}/sysroot/usr/lib/gcc"
    find . -type f -or -type l \
        -exec /usr/bin/test -x {} \; \
        -exec /bin/rm {} \;
    xpopd
fi
rsync -a \
    "${SYSROOT_DIR}/sysroot/" \
    "${BUILD_DIR}/sysroot-install/${TARGET_TUPLE}/sysroot" ||
    die "sysroot transfer failed"
xpopd
