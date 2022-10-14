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

# shellcheck disable=SC2155

configure_host_vars() {
    env_exists WPI_HOST_NAME
    env_exists WPI_HOST_TUPLE
    env_exists HOST_TUPLE

    if [ "$WPI_HOST_NAME" = "Mac" ]; then
        local xcode_arch_flag
        local xcode_sdk_flag
        local xcrun_find
        xcode_sdk_flag="-isysroot $(xcrun --show-sdk-path)"
        xcrun_find="xcrun --sdk macosx -f"
        case "${WPI_HOST_TUPLE}" in
        arm64* | aarch64*) xcode_arch_flag="-arch arm64" ;;
        x86_64*) xcode_arch_flag="-arch x86_64" ;;
        *) die "Unsupported Canadian config" ;;
        esac

        export AR="$($xcrun_find ar)"
        export AS="$($xcrun_find as) $xcode_arch_flag"
        export LD="$($xcrun_find ld) $xcode_arch_flag $xcode_sdk_flag"
        export NM="$($xcrun_find nm) $xcode_arch_flag"
        export STRIP="$($xcrun_find strip) $xcode_arch_flag"
        export RANLIB="$($xcrun_find ranlib)"
        export OBJDUMP="$($xcrun_find objdump)"
        export CC="$($xcrun_find gcc) $xcode_arch_flag $xcode_sdk_flag"
        export CXX="$($xcrun_find g++) $xcode_arch_flag $xcode_sdk_flag"
    else
        export AR="/usr/bin/${HOST_TUPLE}-ar"
        export AS="/usr/bin/${HOST_TUPLE}-as"
        export LD="/usr/bin/${HOST_TUPLE}-ld"
        export NM="/usr/bin/${HOST_TUPLE}-nm"
        export RANLIB="/usr/bin/${HOST_TUPLE}-ranlib"
        export STRIP="/usr/bin/${HOST_TUPLE}-strip"
        export OBJCOPY="/usr/bin/${HOST_TUPLE}-objcopy"
        export OBJDUMP="/usr/bin/${HOST_TUPLE}-objdump"
        export READELF="/usr/bin/${HOST_TUPLE}-readelf"
        export CC="/usr/bin/${HOST_TUPLE}-gcc"
        export CXX="/usr/bin/${HOST_TUPLE}-g++"
    fi
}

configure_target_vars() {
    env_exists TARGET_PREFIX

    define_target_export() {
        local var="${1}_FOR_TARGET"
        local tool="${TARGET_PREFIX}$2"
        if [ "${!var}" ]; then
            die "$var is already set with '${!var}'"
        else
            export "${var}"="/tmp/frc/bin/${tool}"
        fi
    }

    define_target_export AR ar
    define_target_export AS as
    define_target_export LD ld
    define_target_export NM nm
    define_target_export RANLIB ranlib
    define_target_export STRIP strip
    define_target_export OBJCOPY objcopy
    define_target_export OBJDUMP objdump
    define_target_export READELF readelf
    define_target_export CC gcc
    define_target_export CXX g++
    define_target_export GCC gcc
    define_target_export GFORTRAN gfortran
}

gcc_update_target_list() {
    env_exists SYSROOT_BUILD_PATH
    gcc_need_lib_build() {
        local lib="${SYSROOT_BUILD_PATH}/usr/lib/$1"
        if [ "$TARGET_LIB_REBUILD" = "true" ]; then
            return 0
        fi
        if compgen -G "${lib}.so*" >/dev/null; then
            return 1
        fi
        return 0
    }
    if gcc_need_lib_build libgcc_s; then
        GCC_TASKS+=(
            target-libgcc
        )
    fi
    if gcc_need_lib_build libatomic; then
        GCC_TASKS+=(
            target-libatomic
        )
    fi
    if gcc_need_lib_build libasan || gcc_need_lib_build libubsan; then
        GCC_TASKS+=(
            target-libsanitizer
        )
    fi
    if gcc_need_lib_build libstdc++ && [ "${TARGET_ENABLE_CXX}" = true ]; then
        GCC_TASKS+=(
            target-libstdc++-v3
        )
    fi
    if gcc_need_lib_build libgfortran && [ "${TARGET_ENABLE_FORTRAN}" = true ]; then
        GCC_TASKS+=(
            target-libgfortran
        )
    fi
}

is_lib_rebuild_required() {
    local GCC_TASKS
    GCC_TASKS=()
    gcc_update_target_list
    if [ "${#GCC_TASKS[@]}" -gt 0 ]; then
        return 0
    fi
    return 1
}
