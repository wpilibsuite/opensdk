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

# We are building GMP so we can use GDB 11+. While
# GCC also needs GMP, we don't use this build because
# autoconf will complain about GMP not being installed
# in some cases (such as Intel -> M1 canadian builds).

source "$(dirname "$0")/common.sh"

if ! is_final_toolchain; then
    exit 0
fi

rm -rf "${BUILD_DIR}/gmp-build" "${BUILD_DIR}/gmp-install"
mkdir "${BUILD_DIR}/gmp-build"

xcd "${BUILD_DIR}/gmp-build"
process_background "Configuring GMP" \
    "$DOWNLOAD_DIR/gmp-${V_GMP}/configure" \
    "${CONFIGURE_COMMON_LITE[@]}" \
    --enable-static \
    --disable-shared ||
    die "GMP configure failed"
process_background "Building GMP" \
    make -j"$JOBS" || die "GMP build failed"
process_background "Installing GMP" \
    make DESTDIR="${BUILD_DIR}/gmp-install" \
    install-strip || die "GMP install failed"
