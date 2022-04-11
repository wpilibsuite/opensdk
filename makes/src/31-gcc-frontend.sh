#! /usr/bin/env bash

# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh"
source "$(dirname "$0")/utils/conf-gcc.sh"

xcd "${BUILD_DIR}/gcc-build"

# Build the core compiler without libraries
gcc_make_multi gcc
