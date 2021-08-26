#! /usr/bin/env bash

source "$(dirname "$0")/version.env" || exit
source "${SCRIPT_DIR}/downloads_tools.sh" || exit

signed sig https://ftp.gnu.org/gnu/gcc/gcc-${V_GCC}/gcc-${V_GCC}.tar.gz

python3 -m opensysroot \
    ubuntu \
    "${TARGET_PORT}" \
    focal \
    .
mv "./ubuntu/focal/${TARGET_PORT}/sysroot/"* "$REPACK_DIR"
sysroot-package
 