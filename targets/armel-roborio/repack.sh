#! /usr/bin/env bash

set -e
SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/version.env" || exit
source "$SCRIPT_DIR/../../scripts/repack_tools.sh" || exit

WORK_DIR="$PWD"
REPACK_DIR="$1"

# clean up old files
rm -rf "${REPACK_DIR}"

# Stage 1: Extract ipks
mkdir -p "${REPACK_DIR}"
cp *.ipk "${REPACK_DIR}"
for deb in *.ipk; do
	echo "$deb"
	unpack-ipk "$deb"
done
rm "${REPACK_DIR}"/*.ipk

# Stage 2: Merge ipks
merge-unpacked-ipk

# Stage 3: Clean Up Sysroot
sysroot-clean
find "${REPACK_DIR}" -name .install -delete

# Stage 4: Rename tuple
# sysroot-tuple-rename \
# 	"arm-nilrt-linux-gnueabi" "${TARGET_TUPLE}"

# Stage 5: Package
sysroot-package "${REPACK_DIR}" "${DOWNLOAD_DIR}"
