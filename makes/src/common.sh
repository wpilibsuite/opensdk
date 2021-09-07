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

CONFIGURE_COMMON=(
    "--build=${BUILD_TUPLE}"
    "--host=${HOST_TUPLE}"
    "--target=${TARGET_TUPLE}"
    "--prefix=${WPI_HOST_PREFIX}"
    "--program-prefix=${TARGET_PREFIX}"
    "--enable-lto"
    "--disable-nls"
    "--disable-werror"
    "--disable-dependency-tracking"
    "--with-sysroot=${SYSROOT_PATH}"
    "--with-build-sysroot=${SYSROOT_BUILD_PATH}"
)

PATH="${WPI_HOST_PREFIX}/bin:${PATH}"
PATH="/opt/frc/bin:${PATH}"

export CONFIGURE_COMMON PATH
