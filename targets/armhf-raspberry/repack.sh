#! /usr/bin/env bash

set -e
SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/version.env" || exit
source "$SCRIPT_DIR/../../scripts/repack_tools.sh" || exit

REPACK_DIR="$1"

repack-debian "$REPACK_DIR" "$DOWNLOAD_DIR" "$TARGET_TUPLE" "$V_GCC"
