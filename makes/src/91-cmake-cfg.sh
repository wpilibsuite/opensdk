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

source "$(dirname "$0")/common.sh"

rm -rf "${BUILD_DIR}/cmake-install"
mkdir -p "${BUILD_DIR}/cmake-install/${WPI_HOST_PREFIX}"
xcd "${BUILD_DIR}/cmake-install/${WPI_HOST_PREFIX}"

case "${TARGET_TUPLE}" in
arm* | aarch64*)
    PROCESSOR=arm
    ;;
x86_64*)
    PROCESSOR=AMD64
    ;;
esac

case "${WPI_HOST_NAME}" in
Windows)
    HOST_SUFFIX=".exe"
    ;;
Linux | Mac)
    HOST_SUFFIX=""
    ;;
esac

cat <<EOF >toolchain-config.cmake
set(TOOLCHAIN_TRIPLE ${TARGET_TUPLE})
set(TOOLCHAIN_BASE_DIR \${CMAKE_CURRENT_LIST_DIR})
set(TOOLCHAIN_ROOTFS_DIR \${TOOLCHAIN_BASE_DIR}/\${TOOLCHAIN_TRIPLE}/sysroot)

set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_VERSION 1)
set(CMAKE_SYSTEM_PROCESSOR ${PROCESSOR})
set(CMAKE_SYSROOT "\${TOOLCHAIN_ROOTFS_DIR}")

set(CMAKE_C_COMPILER \${TOOLCHAIN_BASE_DIR}/bin/${TARGET_PREFIX}gcc${HOST_SUFFIX})
set(CMAKE_CXX_COMPILER \${TOOLCHAIN_BASE_DIR}/bin/${TARGET_PREFIX}g++${HOST_SUFFIX})
set(CMAKE_Fortran_COMPILER \${TOOLCHAIN_BASE_DIR}/bin/${TARGET_PREFIX}gfortran${HOST_SUFFIX})

set(CMAKE_AR \${TOOLCHAIN_BASE_DIR}/bin/${TARGET_PREFIX}ar${HOST_SUFFIX})
set(CMAKE_AS \${TOOLCHAIN_BASE_DIR}/bin/${TARGET_PREFIX}as${HOST_SUFFIX})
set(CMAKE_NM \${TOOLCHAIN_BASE_DIR}/bin/${TARGET_PREFIX}nm${HOST_SUFFIX})
set(CMAKE_LINKER \${TOOLCHAIN_BASE_DIR}/bin/${TARGET_PREFIX}ld${HOST_SUFFIX})

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

EOF
