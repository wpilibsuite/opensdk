#! /usr/bin/env bash

# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh"

if [ "$CANADIAN_STAGE_ONE" = "true" ]; then
    exit 0
fi

rm -rf "${BUILD_DIR}/expat-build"
mkdir "${BUILD_DIR}/expat-build"

xpushd "${BUILD_DIR}/expat-build"
process_background "Configuring expat" \
    "$DOWNLOAD_DIR/expat-${V_EXPAT}/configure" \
    "${CONFIGURE_COMMON_LITE[@]}" \
    --enable-shared=no \
    --enable-static=yes ||
    die "expat configure failed"
process_background "Building expat" \
    make -j"$JOBS" || die "expat build failed"
process_background "Installing expat" \
    make DESTDIR="${BUILD_DIR}/expat-install" \
    install-strip || die "expat install failed"
xpopd
