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

rm -rf "${BUILD_DIR}/frcmake-build"
mkdir "${BUILD_DIR}/frcmake-build"

xpushd "${BUILD_DIR}/frcmake-build"
process_background "Configuring FRCMake" \
    "$DOWNLOAD_DIR/make-${V_MAKE}/configure" \
    --build="${BUILD_TUPLE}" \
    --host="${HOST_TUPLE}" \
    --prefix="${WPI_HOST_PREFIX}" \
    --program-prefix="frc" \
    --disable-nls ||
    die "frcmake configure failed"
process_background "Building FRCMake" \
    make -j"$JOBS" || die "frcmake build failed"
process_background "Installing FRCMake" \
    make DESTDIR="${BUILD_DIR}/frcmake-install" \
    install-strip || die "frcmake install failed"
xpopd
