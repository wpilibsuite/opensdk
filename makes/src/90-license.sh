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

source "$(dirname "$0")/common.sh"

license_copy() {
    local proj_name="$1"
    local proj_dir="$2"
    find "$proj_dir" -follow -type f \( -name "COPYING*" -o -name "LICENSE*" \) | while read -r file; do
        local dstdir
        dstdir="${file%/*}"
        dstdir="${BUILD_DIR}/license-install/${WPI_HOST_PREFIX}/share/licenses/${proj_name}/${dstdir#"${proj_dir}"}"
        mkdir -p "${dstdir}"
        cp "${file}" "${dstdir}" || return
    done
}

rm -rf "${BUILD_DIR}/license-install"

license_copy binutils "${DOWNLOAD_DIR}/binutils-${V_BIN}"
license_copy gcc "${DOWNLOAD_DIR}/gcc-${V_GCC}"
license_copy gdb "${DOWNLOAD_DIR}/gdb-${V_GDB}"
license_copy make "${DOWNLOAD_DIR}/make-${V_MAKE}"

license_copy expat "${DOWNLOAD_DIR}/expat-${V_EXPAT}"
license_copy gmp "${DOWNLOAD_DIR}/gmp-${V_GMP}"

mkdir "${BUILD_DIR}/license-install/${WPI_HOST_PREFIX}/share/licenses/opensdk"
cp "${ROOT_DIR}/COPYING" \
    "${BUILD_DIR}/license-install/${WPI_HOST_PREFIX}/share/licenses/opensdk"
