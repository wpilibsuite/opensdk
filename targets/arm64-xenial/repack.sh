#! /usr/bin/env bash

set -e
SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/version.env" || exit
source "$SCRIPT_DIR/../../scripts/repack_tools.sh" || exit

REPACK_DIR="$1"

# redefine as there are xenial quirks
# that need to be addressed.
function fix-headers() {
    FULL_VER="${1}"
    MAJOR_VER="${FULL_VER/\.*/}"

    mv "${REPACK_DIR}"/usr/lib/gcc/${TARGET_TUPLE}/{${MAJOR_VER},${FULL_VER}} || true
    rm "${REPACK_DIR}"/usr/include/${TARGET_TUPLE}/c++/${FULL_VER} || true
    rm "${REPACK_DIR}"/usr/include/${TARGET_TUPLE}/c++/${V_GCC_SYSROOT} || true
    mv "${REPACK_DIR}"/usr/include/${TARGET_TUPLE}/c++/{${MAJOR_VER},${FULL_VER}} || true
    rm "${REPACK_DIR}"/usr/include/c++/${FULL_VER} || true
    rm "${REPACK_DIR}"/usr/include/c++/${V_GCC_SYSROOT} || true
    mv "${REPACK_DIR}"/usr/include/c++/{${MAJOR_VER},${FULL_VER}} || true
}

repack-debian "$REPACK_DIR" "$DOWNLOAD_DIR" "$TARGET_TUPLE" "$V_GCC"
