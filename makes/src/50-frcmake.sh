#! /usr/bin/env bash

# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh"

if [ "$CANADIAN_STAGE_ONE" = "true" ]; then
    exit 0
fi

rm -rf "${BUILD_DIR}/frcmake-build"
mkdir "${BUILD_DIR}/frcmake-build"

xpushd "${BUILD_DIR}/frcmake-build"
"$DOWNLOAD_DIR/make-${V_MAKE}/configure" \
    --build="${BUILD_TUPLE}" \
    --host="${HOST_TUPLE}" \
    --prefix="${WPIPREFIX}" \
    --program-prefix="frc" \
    --disable-nls ||
    die "frcmake configure failed"
make -j"$JOBS" || die "frcmake build failed"
DESTDIR="${BUILD_DIR}/frcmake-install" make \
    install || die "frcmake install failed"
xpopd
