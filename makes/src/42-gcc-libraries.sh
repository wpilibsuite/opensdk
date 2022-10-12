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
source "$(dirname "$0")/utils/conf-gcc.sh"

if is_step_backend && ! is_lib_rebuild_required; then
    exit 0
fi

xcd "${BUILD_DIR}/gcc-build"

GCC_TASKS=()
gcc_update_target_list

for task in "${GCC_TASKS[@]}"; do
    gcc_make_multi "$task"
done

if [ -d "${BUILD_DIR}/gcc-install/tmp/frc/${TARGET_TUPLE}/lib" ]; then
    # Older versions of GCC want to place target libraries in a different
    # location than what is set via the --libdir option. But binutils
    # still looks for the libraries in the --libdir option. So this causes
    # crossbuilds that require any extra library that was not already
    # present to fail when linking. This is a workaround for that.
    rsync -aEL \
        "${BUILD_DIR}/gcc-install/tmp/frc/${TARGET_TUPLE}/lib/" \
        "${BUILD_DIR}/gcc-install/tmp/frc/${TARGET_TUPLE}/sysroot/usr/lib/"
    rm -rf "${BUILD_DIR}/gcc-install/tmp/frc/${TARGET_TUPLE}/lib"
fi

if [ "${TARGET_LIB_REBUILD}" = "true" ]; then
    # Duplicate the GCC runtime artifacts to a seperate directory
    # so it can later be scp'd to the roboRIO.
    rsync -aEL \
        "${BUILD_DIR}/gcc-install/tmp/frc/${TARGET_TUPLE}/sysroot/usr/lib/" \
        "${BUILD_DIR}/gcc-install/tmp/frc/${TARGET_TUPLE}/gcclib/"
    # We don't need the static libraries of the GCC runtime
    rm -r "${BUILD_DIR}/gcc-install/tmp/frc/${TARGET_TUPLE}/gcclib/gcc"
fi
