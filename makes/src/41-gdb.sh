#! /usr/bin/env bash

# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh"

if [ "$CANADIAN_STAGE_ONE" = "true" ]; then
    exit 0
fi

rm -rf "${BUILD_DIR}/gdb-build"
mkdir "${BUILD_DIR}/gdb-build"

xpushd "${BUILD_DIR}/gdb-build"
"$DOWNLOAD_DIR/gdb-${V_GDB}/configure" \
    "${CONFIGURE_COMMON[@]}" \
    --with-expat \
    --with-libexpat-prefix="${BUILD_DIR}/expat-install/${WPI_HOST_PREFIX}" \
    --disable-debug \
    --disable-python \
    --disable-sim ||
    die "gdb configure failed"
make -j"$JOBS" || die "gdb build failed"
DESTDIR="${BUILD_DIR}/gdb-install" make \
    install || die "gdb install failed"
xpopd
