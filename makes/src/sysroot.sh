#! /usr/bin/bash

# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh"

rm -rf "${BUILD_DIR}/sysroot-install"
mkdir -p "${BUILD_DIR}/sysroot-install/${TARGET_TUPLE}"

python3 -m opensysroot \
    "${TARGET_DISTRO}" \
    "${TARGET_PORT}" \
    "${TARGET_DISTRO_RELEASE}" \
    . || die "opensysroot failed"
mv "./${TARGET_DISTRO}/${TARGET_DISTRO_RELEASE}/${TARGET_PORT}/sysroot/"* \
    "${BUILD_DIR}/sysroot-install/${TARGET_TUPLE}" ||
    die "sysroot transfer failed"

# xpushd "/tmp"
# echo "download dir ${DOWNLOAD_DIR}"
# rm -rf "${DOWNLOAD_DIR}/sysroot-libc-linux"
# mv "${REPACK_DIR}" "${DOWNLOAD_DIR}/sysroot-libc-linux"
# mkdir "${REPACK_DIR}"
# xpushd "${DOWNLOAD_DIR}"
# tar cjf sysroot-libc-linux.tar.bz2 sysroot-libc-linux --owner=0 --group=0
# xpopd
# xpopd

# xpushd "${BUILD_DIR}"

# rm -rf sysroot-*
# tar xf "${DOWNLOAD_DIR}/sysroot-libc-linux.tar.bz2"
# mkdir -p sysroot-install/
# mv sysroot-libc-linux/ "sysroot-install/${TARGET_TUPLE}"

# xpopd
