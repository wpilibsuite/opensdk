#! /usr/bin/env bash

# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh"

rm -rf "${BUILD_DIR}/frcmake-build"
mkdir "${BUILD_DIR}/frcmake-build"

xpushd "${BUILD_DIR}/frcmake-build"
process_background "Configuring FRCMake" \
    "$DOWNLOAD_DIR/make-${V_MAKE}/configure" \
    --build="${BUILD_TUPLE}" \
    --host="${HOST_TUPLE}" \
    --prefix="${WPI_HOST_PREFIX}" \
    --program-prefix="frc" \
    --disable-nls ||
    die "frcmake configure failed"
process_background "Building FRCMake" \
    make -j"$JOBS" || die "frcmake build failed"
process_background "Installing FRCMake" \
    make DESTDIR="${BUILD_DIR}/frcmake-install" \
    install || die "frcmake install failed"
xpopd
