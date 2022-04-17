#! /usr/bin/env bash

source "$(dirname "$0")/common.sh"

if ! is_final_toolchain; then
    exit 0
fi

if ! is_zstd_needed; then
    exit 0
fi

rm -rf "${BUILD_DIR}/zstd-build"
mkdir "${BUILD_DIR}/zstd-build"