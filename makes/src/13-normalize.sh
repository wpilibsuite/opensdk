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

# This script is only to cleanup the sysroot and normalize
# and differences in the filesystem layout that exist between
# Debian and NI Linux. The goal is to have everyone follow a
# layout similar to NI Linux as it is easier to navigate.

# We do however modify the NI Linux layout to have libgcc_s
# in /usr/lib instead of /lib out of convenience. While we
# could move individual files to the correct location, it
# would be easier to cleanup and rebuild as the libgcc
# startup files (crt*.o) are in the wrong location.

# The Debian filesystem is better for multilib environments
# but this causes issues with a more vanilla version of
# binutils and GCC. So by using the NI Linux layout, we can
# avoid patching/hacking the build tools.

source "$(dirname "$0")/common.sh"

xcd "${BUILD_DIR}/sysroot-install/${TARGET_TUPLE}/sysroot"

if [ "${TARGET_DISTRO}" = "roborio" ] ||
    [ "${TARGET_DISTRO}" = "roborio-academic" ]; then
    # Force rebuild of libgcc and its startup files
    rm -rf lib/libgcc*
    rm -rf usr/lib/crtbegin*.o
    rm -rf usr/lib/crtend*.o
    rm -rf usr/lib/crtfastmath*.o
    rm -rf usr/lib/gcc

    # Why is this here on the rio?
    rm -rf lib/cpp

    # Quirk with the academic branch where the headers have the full version
    # number, but the rest of the project expects this to be the major number.
    if [ -d "usr/include/c++/${V_GCC}" ]; then
        mv "usr/include/c++/${V_GCC}" "usr/include/c++/${V_GCC/.*/}"
    fi

else
    rm -rf usr/lib/audit
    rm -rf usr/lib/bfd-plugins
    rm -rf usr/lib/compat-ld
    rm -rf usr/lib/gold-ld
    rm -rf usr/lib/ldscripts
    rm -rf usr/lib/mime
    rm -rf usr/lib/tar
fi
