#! /usr/bin/env bash
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

# shellcheck disable=SC2155

export CFLAGS="$CFLAGS -g -O2"
export CXXFLAGS="$CXXFLAGS -g -O2"

export FFLAGS_FOR_TARGET="-g -O2"
export CFLAGS_FOR_TARGET="-g -O2"
export CXXFLAGS_FOR_TARGET="-g -O2"

source "$(dirname "$0")/utils/funcs.sh"

if [ "${FUNC_ONLY}" = "true" ]; then
    return 0
fi

# If these fail, then others are bad aswell
env_exists V_BIN
env_exists V_GDB
env_exists V_GCC
env_exists WPI_HOST_PREFIX
env_exists DOWNLOAD_DIR

BUILD_TUPLE="${WPI_BUILD_TUPLE}"
HOST_TUPLE="${WPI_HOST_TUPLE}"
SYSROOT_PATH="${WPI_HOST_PREFIX}/${TARGET_TUPLE}/sysroot"
SYSROOT_BUILD_PATH="$BUILD_DIR/sysroot-install/${TARGET_TUPLE}/sysroot"

CONFIGURE_COMMON_LITE=(
    "--build=${BUILD_TUPLE}"
    "--host=${HOST_TUPLE}"
    "--prefix=${WPI_HOST_PREFIX}"
    "--program-prefix=${TARGET_PREFIX}"
    "--disable-nls"
    "--disable-werror"
    "--disable-multilib"
)

CONFIGURE_COMMON=(
    "${CONFIGURE_COMMON_LITE[@]}"
    "--target=${TARGET_TUPLE}"
    "--with-sysroot=${SYSROOT_PATH}"
    "--libdir=${SYSROOT_PATH}/usr/lib"
    "--with-build-sysroot=${SYSROOT_BUILD_PATH}"
)

export PATH="/tmp/frc/bin:${PATH}"
export CONFIGURE_COMMON_LITE CONFIGURE_COMMON
if [ "${BUILD_TUPLE}" != "${HOST_TUPLE}" ]; then
    # Manually tell autoconf what tools to use as the build, host, and target
    # compilers may be intended for different systems even though they have
    # the same prefix due to the tuple matching.
    configure_host_vars
    configure_target_vars
fi
