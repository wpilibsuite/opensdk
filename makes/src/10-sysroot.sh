#! /usr/bin/bash

set -e
FUNC_ONLY=true

# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh"

rm -rf "${BUILD_DIR}/sysroot-build"
rm -rf "${BUILD_DIR}/sysroot-install"
mkdir "${BUILD_DIR}/sysroot-build"
mkdir -p "${BUILD_DIR}/sysroot-install/${TARGET_TUPLE}/sysroot"

ARGS=(
    "${TARGET_DISTRO}"
    "${TARGET_PORT}"
    "${TARGET_DISTRO_RELEASE}"
)
if [ "$TARGET_LIB_REBUILD" ]; then
    ARGS+=("--minimal-toolchain")
fi

xpushd "${BUILD_DIR}/sysroot-build"
python3 -m opensysroot \
    "${ARGS[@]}" \
    . || die "opensysroot failed"
SYSROOT_DIR="${PWD}/${TARGET_DISTRO}/${TARGET_DISTRO_RELEASE}/${TARGET_PORT}"
if ! [ "$TARGET_LIB_REBUILD" ]; then
    xpushd "${SYSROOT_DIR}/sysroot/usr/lib/gcc"
    find . -type f -or -type l \
        -exec /usr/bin/test -x {} \; \
        -exec /bin/rm {} \;
    xpopd
fi
rsync -a \
    "${SYSROOT_DIR}/sysroot/" \
    "${BUILD_DIR}/sysroot-install/${TARGET_TUPLE}/sysroot" ||
    die "sysroot transfer failed"
xpopd
