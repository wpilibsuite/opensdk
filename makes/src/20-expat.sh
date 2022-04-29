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

# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh"

if [ "$CANADIAN_STAGE_ONE" = "true" ]; then
    exit 0
fi

rm -rf "${BUILD_DIR}/expat-build"
mkdir "${BUILD_DIR}/expat-build"

xpushd "${BUILD_DIR}/expat-build"
process_background "Configuring expat" \
    "$DOWNLOAD_DIR/expat-${V_EXPAT}/configure" \
    "${CONFIGURE_COMMON_LITE[@]}" \
    --enable-shared=no \
    --enable-static=yes ||
    die "expat configure failed"
process_background "Building expat" \
    make -j"$JOBS" || die "expat build failed"
process_background "Installing expat" \
    make DESTDIR="${BUILD_DIR}/expat-install" \
    install-strip || die "expat install failed"
xpopd
