#! /usr/bin/env bash

set -e
SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/version.env" || exit
source "$SCRIPT_DIR/../../scripts/repack_tools.sh" || exit

THIS_DIR="$PWD"
REPACK_DIR="$1"

# clean up old files
rm -rf "${REPACK_DIR}"

echo "Stage 1: Extract Debs"
mkdir -p "${REPACK_DIR}"
cp *.deb "${REPACK_DIR}"
for deb in *.deb; do
    echo "$deb"
    unpack-deb "${REPACK_DIR}" "$deb"
done
rm "${REPACK_DIR}"/*.deb

echo "Stage 2: Merge Debs"
merge-unpacked-deb "${REPACK_DIR}"

echo "Stage 3: Clean Up Sysroot"
sysroot-clean "${REPACK_DIR}"

echo "Stage 4: Rename tuple"
sysroot-tuple-rename "${REPACK_DIR}" "${V_GCC/\.*/}" \
    "arm-linux-gnueabihf" "${TARGET_TUPLE}"

echo "Stage 5: Clean Up Headers"
fix-headers "${REPACK_DIR}" "${V_GCC}"

echo "Stage 6: Fix symlinks"
fix-links "${REPACK_DIR}" "${REPACK_DIR}"/usr/lib/$TARGET_TUPLE
fix-links "${REPACK_DIR}" "${REPACK_DIR}"/usr/lib/gcc/$TARGET_TUPLE/${V_GCC/\.*/}

echo "Stage 7: Package"
sysroot-package "${REPACK_DIR}" "${DOWNLOAD_DIR}"
