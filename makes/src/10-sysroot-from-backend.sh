#! /usr/bin/bash

set -e
FUNC_ONLY=true

# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh"

rm -rf "${BUILD_DIR}/sysroot-install"
mkdir "${BUILD_DIR}/sysroot-install"

tar -xf "${OUTPUT_DIR}/${TARGET_TUPLE}.tar" -C "${BUILD_DIR}/sysroot-install"
