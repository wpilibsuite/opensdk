#! /usr/bin/env bash

# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh"
source "$(dirname "$0")/utils/conf-gcc.sh"

if is_step_backend && ! is_lib_rebuild_required; then
    exit 0
fi

xcd "${BUILD_DIR}/gcc-build"

# Build the core compiler without libraries
gcc_make_multi gcc
