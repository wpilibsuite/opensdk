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

function gcc_make_multi() {
    function _make() {
        make -j"$JOBS" "${@}" || return
    }
    function _make_installer() {
        make DESTDIR="${BUILD_DIR}/gcc-install" "${@}" || return
    }

    process_background "Building GCC '$1'" _make "all-$1" ||
        die "GCC build '$1'"
    process_background "Installing GCC '$1'" _make_installer "install-strip-$1" ||
        die "GCC install '$1'"
}

CONFIGURE_GCC=(
    "--build=${BUILD_TUPLE}"
    "--host=${HOST_TUPLE}"
    "--target=${TARGET_TUPLE}"
    "--prefix=${WPI_HOST_PREFIX}"
    "--program-prefix=${TARGET_PREFIX}"
    "--disable-werror"
    "--disable-nls"

    "--libdir=${SYSROOT_PATH}/usr/lib"
    "--with-sysroot=${SYSROOT_PATH}"
    "--with-build-sysroot=${SYSROOT_BUILD_PATH}"

    "--enable-threads=posix"
    "--enable-shared"
    "--with-gcc-major-version-only"
    "--enable-linker-build-id"
    "--enable-__cxa_atexit" # Should be enabled on glibc devices
    "--with-gxx-include-dir=${SYSROOT_PATH}/usr/include/c++/${V_GCC/.*/}"
)

if [ "${V_GCC/.*/}" -ge 10 ]; then
    # ZSTD is a new dependency for GCC 10+ but is for LTO which
    # we do not use.
    CONFIGURE_GCC+=(
        "--without-zstd"
    )
fi

if [ "$TARGET_ARCH" ]; then
    CONFIGURE_GCC+=("--with-arch=${TARGET_ARCH}")
fi

if [ "$TARGET_CPU" ]; then
    CONFIGURE_GCC+=("--with-cpu=${TARGET_CPU}")
fi

if [ "$TARGET_FLOAT" ]; then
    CONFIGURE_GCC+=("--with-float=${TARGET_FLOAT}")
fi

if [ "$TARGET_FPU" ]; then
    CONFIGURE_GCC+=("--with-fpu=${TARGET_FPU}")
fi

if [ "${TARGET_DISTRO}" = "roborio" ] ||
    [ "${TARGET_DISTRO}" = "roborio-academic" ]; then
    # Pulled by running gcc -v on target device
    CONFIGURE_GCC+=(
        "--disable-libmudflap"
        "--enable-c99"
        "--enable-symvers=gnu"
        "--enable-long-long"
        "--enable-libstdcxx-pch"
        "--enable-libssp"
        "--enable-libitm"
        "--enable-initfini-array"
        "--without-long-double-128"
    )
else
    # Pulled by running gcc -v on target devices
    CONFIGURE_GCC+=(
        # Debian specific flags
        "--enable-clocal=gnu"
        "--without-included-gettext"
        "--enable-libstdcxx-debug"
        "--enable-libstdcxx-time=yes"
        "--with-default-libstdcxx-abi=new"
        "--enable-gnu-unique-object"
    )
    case "${TARGET_PORT}" in
    # Debian Port specific flags
    amd64) CONFIGURE_GCC+=(
        "--disable-vtable-verify"
        "--disable-multilib"
        "--enable-libmpx"
    ) ;;
    armhf) CONFIGURE_GCC+=(
        "--disable-libitm"
        "--disable-libquadmath"
        "--disable-libquadmath-support"
    ) ;;
    arm64) CONFIGURE_GCC+=(
        "--disable-libquadmath"
        "--disable-libquadmath-support"
    ) ;;
    esac
fi

enabled_languages="--enable-languages=c"
if [ "${TARGET_ENABLE_CXX}" = "true" ]; then
    enabled_languages+=",c++"
fi
if [ "${TARGET_ENABLE_FORTRAN}" = "true" ]; then
    enabled_languages+=",fortran"
fi
CONFIGURE_GCC+=("$enabled_languages")
