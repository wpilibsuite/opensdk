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

if [ "$CANADIAN_STAGE_ONE" != true ]; then
    echo "[FATAL]: build-frontend-tiny must not be called directly" >&2
    exit 1
fi

set -a
ROOT_DIR="${PWD}"
# shellcheck source=../scripts/setup.sh
source "$ROOT_DIR/scripts/setup.sh"
set +a

mkdir -p "${BUILD_DIR}"
MAKE="make -C ${ROOT_DIR}/makes/ --no-print-directory"
${MAKE} \
    task/10-sysroot-from-backend \
    task/11-sources \
    task/12-patches \
    task/30-binutils \
    task/40-gcc-configure \
    task/41-gcc-tools

rsync -aEL \
    "${BUILD_DIR}/binutils-install/tmp/frc/" \
    "${BUILD_DIR}/gcc-install/tmp/frc/" \
    "/tmp/frc/"
exit
