#! /usr/bin/env bash

# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh"

rm -rf "${BUILD_DIR}/binutils-build"
mkdir "${BUILD_DIR}/binutils-build"

if [ "${TARGET_DISTRO}" != "roborio" ]; then
    # Patch is applied with expected env var for
    # debian targets.
    export APPEND_TOOLLIBDIR=yes
fi

xpushd "${BUILD_DIR}/binutils-build"
"$DOWNLOAD_DIR/binutils-${V_BIN}/configure" \
    "${CONFIGURE_COMMON[@]}" \
    --enable-poison-system-directories \
    --enable-ld \
    --enable-deterministic-archives ||
    die "binutils configure failed"
make -j"$JOBS" || die "binutils build failed"
DESTDIR="${BUILD_DIR}/binutils-install" make \
    install || die "binutils install failed"
if [ "${WPITARGET}" != "Windows" ]; then
    # GCC needs binutils in prefix path
    sudo make install ||
        die "binutils root install failed"
fi
xpopd
