#! /usr/bin/env bash

source "$(dirname "$0")/common.sh"

if ! (is_final_toolchain && is_zstd_needed); then
    exit 0
fi

if ! [ "$CC" ]; then
    CC="cc"
fi

rm -rf "${BUILD_DIR}/zstd-build"
mkdir "${BUILD_DIR}/zstd-build"

xcd "${BUILD_DIR}/zstd-build"

process_background "Building zstd" \
    make -C "${DOWNLOAD_DIR}/zstd-${V_ZSTD}/lib" \
    BUILD_DIR="${BUILD_DIR}/zstd-build" \
    CC="${CC}" CFLAGS="${CFLAGS}" \
    -j"$JOBS" libzstd.a ||
    die "zstd build failed"
process_background "Installing zstd" \
    make -C "${DOWNLOAD_DIR}/zstd-${V_ZSTD}/lib" \
    BUILD_DIR="${BUILD_DIR}/zstd-build" \
    PREFIX="${WPI_HOST_PREFIX}" \
    DESTDIR="${BUILD_DIR}/zstd-install" \
    install-includes install-static ||
    die "zstd install failed"
