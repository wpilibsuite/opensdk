#! /usr/bin/env bash

# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh"
source "$(dirname "$0")/utils/conf-gcc.sh"

rm -rf "${BUILD_DIR}/gcc-build" "${BUILD_DIR}/gcc-install"
mkdir "${BUILD_DIR}/gcc-build" "${BUILD_DIR}/gcc-install"

if ! is_lib_rebuild_required && [ "$BUILD_BACKEND" = true ]; then
    exit 0
fi

xcd "${BUILD_DIR}/gcc-build"
process_background "Configuring GCC" \
    "$DOWNLOAD_DIR/gcc-${V_GCC}/configure" \
    "${CONFIGURE_GCC[@]}" ||
    die "gcc configure failed"
