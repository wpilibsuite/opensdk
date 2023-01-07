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

rm -rf backend-install
mkdir -p backend-install/tmp/frc

# Build backend archive for use by the frontend builds.
rsync -aEL \
    "sysroot-install/" \
    "backend-install/"

if is_lib_rebuild_required; then
    rsync -aEL \
        "gcc-install/tmp/frc/${TARGET_TUPLE}/sysroot" \
        "backend-install/${TARGET_TUPLE}/"
fi

xpushd backend-install
# Build an archive of the custom sysroot
tar -cf "${TARGET_TUPLE}.tar" "${TARGET_TUPLE}"
xpopd

# Place tarball of custom sysroot in the build directory
mv "backend-install/${TARGET_TUPLE}.tar" "."
