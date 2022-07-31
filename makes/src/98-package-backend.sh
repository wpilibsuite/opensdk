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

rm -rf backend-install
mkdir -p backend-install/tmp/frc

if [ "$TARGET_LIB_REBUILD" = "true" ]; then
    # Hack to make the linker behave nicely with a out of tree libgcc.
    # This will take double the space on disk but is compressed
    # within the zip/tgz file.
    # TODO: Remove artifact from the old GCC build to cut down on space.
    rsync -aEL \
        "gcc-install/tmp/frc/${TARGET_TUPLE}/gcclib/" \
        "gcc-install/tmp/frc/${TARGET_TUPLE}/sysroot/usr/lib/"
fi

# Build backend archive for use by the frontend builds.
rsync -aEL \
    "sysroot-install/" \
    "backend-install/"
if [ "$TARGET_LIB_REBUILD" = "true" ]; then
    rsync -aEL \
        "gcc-install/tmp/frc/${TARGET_TUPLE}/gcclib" \
        "backend-install/${TARGET_TUPLE}/"
fi
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
