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

rm -rf "${BUILD_DIR}/binutils-build"
mkdir "${BUILD_DIR}/binutils-build"

if is_step_backend && ! is_lib_rebuild_required; then
    exit 0
fi

# This is a part of the debian specific patch. This is no-op for the roborio.
export APPEND_TOOLLIBDIR=yes
export DEB_TARGET_MULTIARCH="${TARGET_TUPLE}"

export CXXFLAGS="-std=c++11 -Wno-c++11-narrowing"

CONFIGURE_BINUTILS=(
    "--build=${BUILD_TUPLE}"            # Build machine
    "--host=${HOST_TUPLE}"              # Host machine
    "--target=${TARGET_TUPLE}"          # Target machine
    "--prefix=${WPI_HOST_PREFIX}"       # Filesystem prefix
    "--program-prefix=${TARGET_PREFIX}" # Program prefix
    "--disable-werror"                  # Allow host builds to be permissive
    "--disable-nls"                     # Disable localization
    "--disable-multilib"                # Disable multilib for 64-bit targets
    "--enable-gold"

    "--with-sysroot=${SYSROOT_PATH}"
)

xpushd "${BUILD_DIR}/binutils-build"
process_background "Configuring binutils" \
    "$DOWNLOAD_DIR/binutils-${V_BIN}/configure" \
    "${CONFIGURE_BINUTILS[@]}" ||
    die "binutils configure"
process_background "Building binutils" \
    make -j"$JOBS" || die "binutils build failed"
process_background "Installing binutils" \
    make DESTDIR="${BUILD_DIR}/binutils-install" \
    install-strip || die "binutils install failed"
if is_step_backend || (is_step_frontend && [ "$WPI_BUILD_TUPLE" == "$WPI_HOST_TUPLE" ]); then
    # GCC needs binutils in prefix path while building
    # the target libraries. Previously this required
    # the build user to have root access, but now
    # the unix prefix is globally accessible.
    process_background "Installing binutils to system" \
        make install-strip ||
        die "binutils root install failed"
fi
xpopd
