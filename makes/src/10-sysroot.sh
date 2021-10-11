#! /usr/bin/bash

set -e

# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh"

rm -rf "${BUILD_DIR}/sysroot-build"
rm -rf "${BUILD_DIR}/sysroot-install"
mkdir "${BUILD_DIR}/sysroot-build"
mkdir -p "${BUILD_DIR}/sysroot-install/${TARGET_TUPLE}"

xpushd "${BUILD_DIR}/sysroot-build"
python3 -m opensysroot \
    "${TARGET_DISTRO}" \
    "${TARGET_PORT}" \
    "${TARGET_DISTRO_RELEASE}" \
    . || die "opensysroot failed"
SYSROOT_DIR="./${TARGET_DISTRO}/${TARGET_DISTRO_RELEASE}/${TARGET_PORT}/sysroot"
xpushd "${SYSROOT_DIR}/usr/lib/gcc"
find . -type f -perm /111 -exec rm {} \;
xpopd
mv "./${SYSROOT_DIR}/"* \
    "${BUILD_DIR}/sysroot-install/${TARGET_TUPLE}" ||
    die "sysroot transfer failed"
xpopd
