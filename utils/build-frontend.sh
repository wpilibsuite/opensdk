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

# Change directory to project base
cd "$(dirname "$0")/.." || exit

set -a
ROOT_DIR="${PWD}"
# shellcheck source=../scripts/setup.sh
source "$ROOT_DIR/scripts/setup.sh"
set +a

die() {
    echo "[FATAL]: $1" >&2
    exit 1
}

if [ "$WPI_BUILD_TUPLE" != "$WPI_HOST_TUPLE" ]; then
    case "$(uname)" in
    Linux) _os="linux" ;;
    Darwin) _os="macos" ;;
    *)
        die "Unsupported canadian build os"
        ;;
    esac

    case "$(uname -m)" in
    x86_64)
        _arch="x86_64"
        _file_arch="x86[-_]64"
    ;;
    arm64)
        _arch="arm64"
        _file_arch="arm64"
    ;;
    *)
        die "Unsupported canadian build architecture"
        ;;
    esac

    # Recursivly build to setup host to help the canadian build
    CANADIAN_STAGE_ONE=true bash \
        "utils/build-frontend-tiny.sh" \
        "hosts/${_os}_${_arch}.env" "$2" "$3" || exit
    unset _os
    if ! [ -x "/tmp/frc/bin/${TARGET_TUPLE}-gcc" ]; then
        echo "[ERROR]: /tmp/frc/bin/${TARGET_TUPLE} missing"
        bash
        exit 1
    elif ! [[ "$(file "/tmp/frc/bin/${TARGET_TUPLE}-gcc")" =~ $_file_arch ]]; then
        echo "[ERROR]: /tmp/frc/bin/${TARGET_TUPLE} is built incorrectly:"
        file "/tmp/frc/bin/${TARGET_TUPLE}-gcc"
       exit 1
    fi
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
    task/10-sysroot-from-backend \
    task/11-sources \
    task/12-patches \
    task/30-binutils \
    task/20-expat \
    task/21-gmp \
    task/40-gcc-configure \
    task/41-gcc-tools \
    task/50-gdb \
    task/90-license \
    task/91-cmake-cfg \
    task/99-tree

${MAKE} pkg
