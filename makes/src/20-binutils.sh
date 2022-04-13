#! /usr/bin/env bash

# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh"

rm -rf "${BUILD_DIR}/binutils-build"
mkdir "${BUILD_DIR}/binutils-build"

if is_step_backend && ! is_lib_rebuild_required; then
    exit 0
fi

CONFIGURE_BINUTILS=(
    "${CONFIGURE_COMMON[@]}"
    "--enable-poison-system-directories"
    "--enable-ld"
    "--enable-deterministic-archives"
)

xpushd "${BUILD_DIR}/binutils-build"
process_background "Configuring binutils" \
    "$DOWNLOAD_DIR/binutils-${V_BIN}/configure" \
    "${CONFIGURE_BINUTILS[@]}" ||
    die "binutils configure"
process_background "Building binutils" \
    make -j"$JOBS" || die "binutils build failed"
process_background "Installing binutils" \
    make DESTDIR="${BUILD_DIR}/binutils-install" \
    install-strip || die "binutils install failed"
if is_step_backend; then
    # GCC needs binutils in prefix path while building
    # the target libraries. Using sudo here is messy but
    # I do not want to spend the time to work around this.
    process_background "Installing binutils as root" \
        sudo make install-strip ||
        die "binutils root install failed"
fi
xpopd
