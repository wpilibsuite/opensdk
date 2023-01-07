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

# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh"

if [ "$CANADIAN_STAGE_ONE" = "true" ]; then
    exit 0
fi

PROJECT_EXPORT=(
    sysroot
    binutils
    gcc
    gdb
    cmake
)

rm -rf tree-{build,install}
mkdir tree-{build,install}
for project in "${PROJECT_EXPORT[@]}"; do
    if ! [ -d "${project}-install" ]; then
        die "${project} install missing"
    fi
    # -L will destroy symlinks and just duplicate
    rsync -aEL \
        "${project}-install/" tree-build/ ||
        die "rsync tree build failed - $project"
done
xpushd tree-build

TREE_OUT="frc${V_YEAR}/${TOOLCHAIN_NAME}/"

rm -rf "${TREE_OUT}"
mkdir -p "${TREE_OUT}"

rsync -aE "./${TARGET_TUPLE}/" "${TREE_OUT}/${TARGET_TUPLE}"
rsync -aE "./${WPI_HOST_PREFIX}/" "${TREE_OUT}"
rm -rf "./${WPI_HOST_PREFIX}" "./${TARGET_TUPLE}"

xpushd "${TREE_OUT}"
rm -rf include

xpushd bin

if [ -x "${STRIP}" ]; then
    STRIP_CMD="${STRIP}"
elif [ -e "/usr/bin/${HOST_TUPLE}-strip" ]; then
    STRIP_CMD="/usr/bin/${HOST_TUPLE}-strip"
elif [ -e "/usr/bin/${WPI_HOST_TUPLE}-strip" ]; then
    STRIP_CMD="/usr/bin/${WPI_HOST_TUPLE}-strip"
elif [ -e "/usr/bin/llvm-strip" ]; then
    # LLVM strip is architecture agnostic
    STRIP_CMD="/usr/bin/llvm-strip"
elif [ "${WPI_HOST_NAME}" = "Mac" ]; then
    # Xcode strip is just LLVM strip
    STRIP_CMD="strip"
else
    warn "Cannot find proper strip command"
fi

# Remove any executables that may have the incorrect names
for exec in "${TARGET_TUPLE}-${TARGET_PREFIX}"* "${TARGET_TUPLE}"-gcc-*; do
    rm "${exec}" &>/dev/null || true
done

for exec in *; do
    if file "${exec}" | grep -qiF -e "elf" -e "mach-o" -e "pe32+"; then
        "${STRIP_CMD}" "${exec}" || die "Could not strip ${exec}"
    fi
done

xpopd # bin
xpopd # TREE_OUT
xpopd # tree-build

mv "tree-build/frc${V_YEAR}/" "tree-install/frc${V_YEAR}"
