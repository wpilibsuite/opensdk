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

# January 1, 2000. Midnight.
EPOCH="946684800"

source "${ROOT_DIR}/consts.env"
source "${ROOT_DIR}/targets/${TOOLCHAIN_NAME}/version.env"

TREEIN_DIR="${BUILD_DIR}/tree-install/frc${V_YEAR}/"
TREEOUT_TEMPLATE="${TARGET_PORT}-${TOOLCHAIN_NAME}${SUFFIX}-${V_YEAR}-${WPI_HOST_TUPLE}-Toolchain-${V_GCC}"

strip_toolchain() {
    if [ -x "${STRIP}" ]; then
        STRIP_CMD="${STRIP}"
    elif [ -e "/usr/bin/llvm-strip" ]; then
        # LLVM strip is architecture agnostic
        STRIP_CMD="/usr/bin/llvm-strip"
    elif [ -x "${TREEIN_DIR}/${TOOLCHAIN_NAME}/${TARGET_TUPLE}/bin/strip" ]; then
        STRIP_CMD="${TREEIN_DIR}/${TOOLCHAIN_NAME}/${TARGET_TUPLE}/bin/strip"
    else
        warn "Cannot find proper strip command"
    fi

    SYSROOT="${TREEIN_DIR}/${TOOLCHAIN_NAME}/${TARGET_TUPLE}/sysroot"
    for lib in ${SYSROOT}/lib64/* ${SYSROOT}/*/*/* ${SYSROOT}/usr/lib/*/*/*/*; do
        if file "${lib}" | grep -qiF -e "elf "; then
            "${STRIP_CMD}" -S "${lib}" || die "Could not strip ${lib}"
        fi
    done
    TREEOUT_TEMPLATE="${TARGET_PORT}-${TOOLCHAIN_NAME}-${V_YEAR}-${WPI_HOST_TUPLE}-Toolchain-${V_GCC}"
}

nondeterministic() {
    if ! command -v strip-nondeterminism >/dev/null; then
        return
    fi
    # This should make all files in the toolchain have the same
    # timestamp so we can better compare builds.
    strip-nondeterminism -T "$EPOCH" "$1"
}

_archive() {
    rm -f "${OUTPUT_DIR}/$TREEOUT_TEMPLATE.tgz"
    tar -cf "${OUTPUT_DIR}/$TREEOUT_TEMPLATE.tar" .
    nondeterministic "${OUTPUT_DIR}/$TREEOUT_TEMPLATE.tar"
    gzip "${OUTPUT_DIR}/$TREEOUT_TEMPLATE.tar"
    mv "${OUTPUT_DIR}/$TREEOUT_TEMPLATE.tar.gz" "${OUTPUT_DIR}/$TREEOUT_TEMPLATE.tgz"
}

archive() {
    xcd "${TREEIN_DIR}"
    echo "[INFO]: Archiving toolchain"
    _archive || return
    if [ "${TARGET_DISTRO}" != systemcore ]; then
        return
    fi
    echo "[INFO]: Stripping toolchain"
    strip_toolchain
    echo "[INFO]: Archiving stripped toolchain"
    _archive || return
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
            echo "${TREEOUT_TEMPLATE}.tgz"
            exit
            ;;
        esac
        shift
    done
}

argparse "$@"
