#! /usr/bin/env bash

function die() {
    echo "[FATAL]: $1" >&2
    exit 1
}

function xpushd() {
    pushd "$1" >/dev/null || die "pushd failed: $1"
}

function xpopd() {
    popd >/dev/null || die "popd failed"
}

# If these fail, then others are bad aswell
[ "${V_BIN:-fail}" != fail ] || die "V_BIN"
[ "${V_GDB:-fail}" != fail ] || die "V_GDB"
[ "${V_GCC:-fail}" != fail ] || die "V_GCC"
[ "${WPI_HOST_PREFIX:-fail}" != fail ] || die "prefix dir"
[ "${DOWNLOAD_DIR:-fail}" != fail ] || die "Download Dir"
[ "${REPACK_DIR:-fail}" != fail ] || die "Repack Dir"

BUILD_TUPLE="$(gcc -dumpmachine)"
HOST_TUPLE="${WPI_HOST_TUPLE}"
SYSROOT_PATH="${WPI_HOST_PREFIX}/${TARGET_TUPLE}"
SYSROOT_BUILD_PATH="$BUILD_DIR/sysroot-install/$TARGET_TUPLE"

CONFIGURE_COMMON_LITE=(
    "--build=${BUILD_TUPLE}"
    "--host=${HOST_TUPLE}"
    "--prefix=${WPI_HOST_PREFIX}"
    "--program-prefix=${TARGET_PREFIX}"
    "--enable-lto"
    "--disable-nls"
    "--disable-werror"
    "--disable-dependency-tracking"
)

CONFIGURE_COMMON=(
    "${CONFIGURE_COMMON_LITE[@]}"
    "--target=${TARGET_TUPLE}"
    "--with-sysroot=${SYSROOT_PATH}"
    "--with-build-sysroot=${SYSROOT_BUILD_PATH}"
)

export PATH="/opt/frc/bin:${PATH}"
export CONFIGURE_COMMON_LITE CONFIGURE_COMMON
if [ "${PREBUILD_CANADIAN}" = "true" ]; then
    if ! [[ -x "/opt/frc/bin/${TARGET_TUPLE}-gcc" ]]; then
        echo "[DEBUG]: Cannot find ${TARGET_TUPLE}-gcc in /opt/frc/bin"
        die "Stage 1 Canadian toolchain not found in expected location"
    fi
    if [ "${HOST_TUPLE}" = "${TARGET_TUPLE}" ]; then
        # Manually tell autoconf what tools to use as the host and target
        # compilers may be intended for different systems even though they have
        # the same prefix due to the tuple matching.
        AR="/usr/bin/${HOST_TUPLE}-ar"
        export AR
        AS="/usr/bin/${HOST_TUPLE}-as"
        export AS
        LD="/usr/bin/${HOST_TUPLE}-ld"
        export LD
        NM="/usr/bin/${HOST_TUPLE}-nm"
        export NM
        RANLIB="/usr/bin/${HOST_TUPLE}-ranlib"
        export RANLIB
        STRIP="/usr/bin/${HOST_TUPLE}-strip"
        export STRIP
        OBJCOPY="/usr/bin/${HOST_TUPLE}-objcopy"
        export OBJCOPY
        OBJDUMP="/usr/bin/${HOST_TUPLE}-objdump"
        export OBJDUMP
        READELF="/usr/bin/${HOST_TUPLE}-readelf"
        export READELF
        CC="/usr/bin/${HOST_TUPLE}-gcc"
        export CC
        CXX="/usr/bin/${HOST_TUPLE}-g++"
        export CXX

        AR_FOR_TARGET="/opt/frc/bin/${HOST_TUPLE}-ar"
        export AR_FOR_TARGET
        AS_FOR_TARGET="/opt/frc/bin/${HOST_TUPLE}-as"
        export AS_FOR_TARGET
        LD_FOR_TARGET="/opt/frc/bin/${HOST_TUPLE}-ld"
        export LD_FOR_TARGET
        NM_FOR_TARGET="/opt/frc/bin/${HOST_TUPLE}-nm"
        export NM_FOR_TARGET
        RANLIB_FOR_TARGET="/opt/frc/bin/${HOST_TUPLE}-ranlib"
        export RANLIB_FOR_TARGET
        STRIP_FOR_TARGET="/opt/frc/bin/${HOST_TUPLE}-strip"
        export STRIP_FOR_TARGET
        OBJCOPY_FOR_TARGET="/opt/frc/bin/${HOST_TUPLE}-objcopy"
        export OBJCOPY_FOR_TARGET
        OBJDUMP_FOR_TARGET="/opt/frc/bin/${HOST_TUPLE}-objdump"
        export OBJDUMP_FOR_TARGET
        READELF_FOR_TARGET="/opt/frc/bin/${HOST_TUPLE}-readelf"
        export READELF_FOR_TARGET
        CC_FOR_TARGET="/opt/frc/bin/${HOST_TUPLE}-gcc"
        export CC_FOR_TARGET
        GCC_FOR_TARGET="${CC_FOR_TARGET}"
        export GCC_FOR_TARGET
        CXX_FOR_TARGET="/opt/frc/bin/${HOST_TUPLE}-g++"
        export CXX_FOR_TARGET
        GFORTRAN_FOR_TARGET="/opt/frc/bin/${HOST_TUPLE}-gfortran"
        export GFORTRAN_FOR_TARGET
    fi
fi
