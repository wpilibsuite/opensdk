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

# January 1, 2000. Midnight.
EPOCH="946684800"

source "${ROOT_DIR}/consts.env"
source "${ROOT_DIR}/targets/${TOOLCHAIN_NAME}/version.env"

TREEIN_DIR="${BUILD_DIR}/tree-install/frc${V_YEAR}/"
TREEOUT_TEMPLATE="${TARGET_PORT}-${TOOLCHAIN_NAME}-${V_YEAR}-${WPI_HOST_TUPLE}-Toolchain-${V_GCC}"

nondeterministic() {
    if ! command -v strip-nondeterminism >/dev/null; then
        return
    fi
    # This should make all files in the toolchain have the same
    # timestamp so we can better compare builds.
    strip-nondeterminism -T "$EPOCH" "$1"
}

archive_win() {
    rm -f "${OUTPUT_DIR}/$TREEOUT_TEMPLATE.zip"
    zip -r -9 "${OUTPUT_DIR}/$TREEOUT_TEMPLATE.zip" .
    nondeterministic "${OUTPUT_DIR}/$TREEOUT_TEMPLATE.zip"
}

archive_nix() {
    rm -f "${OUTPUT_DIR}/$TREEOUT_TEMPLATE.tgz"
    tar -cf "${OUTPUT_DIR}/$TREEOUT_TEMPLATE.tar" .
    nondeterministic "${OUTPUT_DIR}/$TREEOUT_TEMPLATE.tar"
    gzip "${OUTPUT_DIR}/$TREEOUT_TEMPLATE.tar"
    mv "${OUTPUT_DIR}/$TREEOUT_TEMPLATE.tar.gz" "${OUTPUT_DIR}/$TREEOUT_TEMPLATE.tgz"
}

archive() {
    xcd "${TREEIN_DIR}"
    if [ "${WPI_HOST_NAME}" = Windows ]; then
        archive_win || return
    else
        archive_nix || return
    fi
}

argparse() {
    while [ $# -gt 0 ]; do
        case "$1" in
            --archive)
                archive
                exit
                ;;
            --print-treein)
                echo "$TREEIN_DIR"
                exit
                ;;
            --print-treeout)
                echo "$TREEOUT_TEMPLATE"
                exit
                ;;
            --print-pkg)
                if [ "${WPI_HOST_NAME}" = Windows ]; then
                    echo "${TREEOUT_TEMPLATE}.zip"
                else
                    echo "${TREEOUT_TEMPLATE}.tgz"
                fi
                exit
                ;;
        esac
        shift
    done
}

argparse "$@"
