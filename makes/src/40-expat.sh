#! /usr/bin/env bash

# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh"

if [ "$CANADIAN_STAGE_ONE" = "true" ]; then
    exit 0
fi

rm -rf "${BUILD_DIR}/expat-build"
mkdir "${BUILD_DIR}/expat-build"

xpushd "${BUILD_DIR}/expat-build"
"$DOWNLOAD_DIR/expat-${V_EXPAT}/configure" \
    "${CONFIGURE_COMMON_LITE[@]}" \
    --enable-shared=no \
    --enable-static=yes ||
    die "expat configure failed"
make -j"$JOBS" || die "expat build failed"
DESTDIR="${BUILD_DIR}/expat-install" make \
    install || die "expat install failed"
xpopd

