#! /usr/bin/env bash

set -e
SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/version.env" || exit
source "$SCRIPT_DIR/../../scripts/repack_tools.sh" || exit

THIS_DIR="$PWD"
REPACK_DIR="$1"

# clean up old files
rm -rf "${REPACK_DIR}"

# Stage 1: Extract Debs
mkdir -p "${REPACK_DIR}"
cp *.deb "${REPACK_DIR}"
for deb in *.deb; do
    echo "$deb"
    unpack-deb "${REPACK_DIR}" "$deb"
done
rm "${REPACK_DIR}"/*.deb

# Stage 2: Merge Debs
merge-unpacked-deb "${REPACK_DIR}"

# Stage 3: Clean Up Sysroot
sysroot-clean "${REPACK_DIR}"

# Stage 4: Clean Up Headers
fix-headers "${REPACK_DIR}" "${V_GCC}"

# Stage 5: Fix symlinks
fix-links "${REPACK_DIR}" "${REPACK_DIR}"/usr/lib/$TARGET_TUPLE
fix-links "${REPACK_DIR}" "${REPACK_DIR}"/usr/lib/gcc/$TARGET_TUPLE/${V_GCC}

# Stage 6: Package
sysroot-package "${REPACK_DIR}" "${DOWNLOAD_DIR}"
