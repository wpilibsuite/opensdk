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

if ! is_final_toolchain; then
    exit 0
fi

rm -rf "${BUILD_DIR}/mpfr-build" "${BUILD_DIR}/mpfr-install"
mkdir "${BUILD_DIR}/mpfr-build" "${BUILD_DIR}/mpfr-install"

xcd "${BUILD_DIR}/mpfr-build"
process_background "Configuring mpfr" \
    "$DOWNLOAD_DIR/gcc-${V_GCC}/mpfr/configure" \
    "${CONFIGURE_COMMON_LITE[@]}" \
    --with-gmp="${BUILD_DIR}/gmp-install/${WPI_HOST_PREFIX}" \
    --enable-static \
    --disable-shared ||
    die "mpfr configure failed"
process_background "Building mpfr" \
    make -j"$JOBS" || die "mpfr build failed"
process_background "Installing mpfr" \
    make DESTDIR="${BUILD_DIR}/mpfr-install" \
    install-strip || die "mpfr install failed"
find "${BUILD_DIR}/mpfr-install" -name '*.la' -delete
