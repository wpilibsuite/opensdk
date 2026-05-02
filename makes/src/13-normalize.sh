#! /usr/bin/bash

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

# This script is only to cleanup the sysroot and relocate files in
# the filesystem layout in order to ensure GCC picks up everything
# correctly. Debian and Systemcore/Buildroot both have completed the
# usr merge, which extensively uses symlinks to ensure everything is
# in the right location, but our environments prevent the usage of
# symlinks, so we need to manually relocate libraries to ensure they
# can be found by the toolchain. We also want to mimimize the number
# of relocations to avoid future maintainence issues and to minimize
# the risk of error.

source "$(dirname "$0")/common.sh"

xcd "${BUILD_DIR}/sysroot-install/${TARGET_TUPLE}/sysroot"

# libc.so, libm.a, libm.so all use linker scripts that use absolute
# paths to refer to libraries. The libraries specified inside must be
# relocated for the toolchain to work.
relocate_core_libraries() {
    mkdir -p $2
    mv $1/libm-2.42.a $2/libm-2.42.a
    mv $1/libmvec.a $2/libmvec.a
    mv $1/libc_nonshared.a $2/libc_nonshared.a
}

if [ "${TARGET_DISTRO}" = "systemcore" ]; then
    # Required for <bits/c++config.h> to be in the right spot
    mv "usr/include/c++/${V_GCC/.*/}/aarch64-buildroot-linux-gnu/bits"/* "usr/include/c++/14/bits/"
    mv "usr/include/c++/${V_GCC/.*/}/aarch64-buildroot-linux-gnu/ext"/* "usr/include/c++/14/ext/"
    # We want to minimize library relocations, so it would be good to
    # move everything one time to a place that will require the least
    # number of relocations afterwards. Of the libraries in the
    # linker scripts, /lib64 and /usr/lib64 show up the most
    # (3 times). We will choose move the majority of libraries to
    # /lib64 due to the path being shorter, which may help with
    # Windows path length later.
    relocate_core_libraries usr/lib usr/lib64
    mkdir -p lib
    mv usr/lib/ld-linux-aarch64.so.1 lib/ld-linux-aarch64.so.1
    # Relocate everything
    mv usr/lib lib64
    # Move gcc/aarch64-linux-gnu directory back
    mkdir -p usr/lib
    mv lib64/gcc usr/lib/gcc
else
    mv usr/lib lib
    # For Debian, /lib shows up more often (the scale is tipped by
    # /lib/ld-linux-aarch64.so.1), so move everything there. This
    # means the order of moves is different, as we are moving some
    # libraries back to their original locations.
    relocate_core_libraries lib/aarch64-linux-gnu usr/lib/aarch64-linux-gnu
    # Move gcc/aarch64-linux-gnu directory back
    mv lib/gcc usr/lib/gcc
    rm -rf usr/lib/audit
    rm -rf usr/lib/bfd-plugins
    rm -rf usr/lib/compat-ld
    rm -rf usr/lib/gold-ld
    rm -rf usr/lib/ldscripts
    rm -rf usr/lib/mime
    rm -rf usr/lib/tar
fi
