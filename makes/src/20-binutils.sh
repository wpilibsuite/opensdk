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
process_background "Configuring binutils" \
    "$DOWNLOAD_DIR/binutils-${V_BIN}/configure" \
    "${CONFIGURE_COMMON[@]}" \
    --enable-poison-system-directories \
    --enable-ld \
    --enable-deterministic-archives ||
    die "binutils configure"
process_background "Building binutils" \
    make -j"$JOBS" || die "binutils build failed"
process_background "Installing binutils" \
    make DESTDIR="${BUILD_DIR}/binutils-install" \
    install || die "binutils install failed"
if [ "${PREBUILD_CANADIAN}" != "true" ]; then
    # GCC needs binutils in prefix path
    process_background "Installing binutils as root" \
        sudo make install ||
        die "binutils root install failed"
fi
xpopd
