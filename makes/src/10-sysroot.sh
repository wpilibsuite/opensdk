#! /usr/bin/bash

set -e

# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh"

rm -rf "${BUILD_DIR}/sysroot-build"
rm -rf "${BUILD_DIR}/sysroot-install"
mkdir "${BUILD_DIR}/sysroot-build"
mkdir -p "${BUILD_DIR}/sysroot-install/${TARGET_TUPLE}/sysroot"

xpushd "${BUILD_DIR}/sysroot-build"
python3 -m opensysroot \
    "${TARGET_DISTRO}" \
    "${TARGET_PORT}" \
    "${TARGET_DISTRO_RELEASE}" \
    . || die "opensysroot failed"
SYSROOT_DIR="${PWD}/${TARGET_DISTRO}/${TARGET_DISTRO_RELEASE}/${TARGET_PORT}"
xpushd "${SYSROOT_DIR}/sysroot"
if [ -d "lib64" ]; then
    rm -r "lib64"
fi
xpushd "usr/lib/gcc"
find . -type f -or -type l \
    -exec /usr/bin/test -x {} \; \
    -exec /bin/rm {} \;
xpopd # usr/lib/gcc
xpopd # sysroot
rsync -a \
    "${SYSROOT_DIR}/sysroot/" \
    "${BUILD_DIR}/sysroot-install/${TARGET_TUPLE}/sysroot" ||
    die "sysroot transfer failed"
xpopd
