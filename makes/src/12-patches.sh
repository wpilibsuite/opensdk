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

# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh"

function patch_or_die() {
    if ! [ -e "${1}" ]; then
        die "${1} does not exist"
    fi
    patch -p1 -N -s <"${1}" ||
        die "patch failed: ${1}"
    echo "[INFO]: Applied patch ${1}"
}

function patch_project() {
    local proj
    local src
    local ver
    case "$1" in
    gcc)
        proj="gcc"
        src="gcc-${V_GCC}"
        ver="${V_GCC}"
        ;;
    make)
        proj="make"
        src="make-${V_MAKE}"
        ver="${V_MAKE}"
        ;;
    *) die "Unknown config" ;;
    esac

    function patch_loop() {
        xpushd "${1}"
        for _patch in *; do
            if [[ "$_patch" =~ darwin ]] && [ "$WPI_HOST_NAME" != "Mac" ]; then
                # Do not apply macOS specific patches for Windows and Linux
                # builds
                continue
            fi 
            _patch="${PWD}/$_patch"
            xpushd "${DOWNLOAD_DIR}/${src}"
            patch_or_die "$_patch"
            xpopd
        done
        xpopd
    }

    if [ -d "${PATCH_DIR}/${proj}" ]; then
        xpushd "${PATCH_DIR}/${proj}"
        if [ -d "./any" ]; then
            patch_loop "any"
        fi
        if [ -d "./${ver}" ]; then
            patch_loop "${ver}"
        fi
        xpopd
    fi
}

patch_project gcc
patch_project make

if [ -d "${PATCH_DIR}/targets/consts/${TOOLCHAIN_NAME}" ]; then
    xpushd "${PATCH_DIR}/targets/consts/${TOOLCHAIN_NAME}"
    for _patch in *; do
        _patch="${PWD}/$_patch"
        xpushd "${DOWNLOAD_DIR}/gcc-${V_GCC}"
        patch_or_die "$_patch"
        xpopd
    done
    xpopd
fi
