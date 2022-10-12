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

rm -rf "${BUILD_DIR}/gdb-build"
mkdir "${BUILD_DIR}/gdb-build"

xpushd "${BUILD_DIR}/gdb-build"
process_background "Configuring GDB" \
    "$DOWNLOAD_DIR/gdb-${V_GDB}/configure" \
    "${CONFIGURE_COMMON[@]}" \
    --with-expat \
    --with-libexpat-prefix="${BUILD_DIR}/expat-install/${WPI_HOST_PREFIX}" \
    --with-gmp \
    --with-libgmp-prefix="${BUILD_DIR}/gmp-install/${WPI_HOST_PREFIX}" \
    --disable-debug \
    --disable-python \
    --disable-sim ||
    die "gdb configure failed"
process_background "Building GDB" \
    make -j"$JOBS" || die "gdb build failed"
# make is having issues with strip for GDB install
process_background "Installing GDB" \
    make DESTDIR="${BUILD_DIR}/gdb-install" \
    install || die "gdb install failed"
xpopd
