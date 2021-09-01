#! /usr/bin/bash
# shellcheck disable=SC2010

# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh"

if ls -l "${PATCH_DIR}/" | grep -q "gcc-${V_GCC//.*/}"; then
    xpushd "${DOWNLOAD_DIR}/gcc-${V_GCC}"
    for file in "${PATCH_DIR}"/gcc-"${V_GCC//.*/}"_*.patch; do
        patch -p1 -N -s <"$file" ||
            die "Versioned patch failed: ${file}"
    done
    xpopd
fi

if [ -e "${PATCH_DIR}/hosts/${WPIHOST}/make.patch" ]; then
    xpushd "${DOWNLOAD_DIR}/make-${V_MAKE}"
    patch -p1 -N -s <"${PATCH_DIR}/hosts/${WPIHOST}/make.patch" ||
        die "frcmake patch failed"
    xpopd
fi

if [ "${TARGET_DISTRO}" = "roborio" ]; then
    xpushd "${DOWNLOAD_DIR}/gcc-${V_GCC}"
    patch -p1 -N -s <"${PATCH_DIR}/roborio/gcc.patch" ||
        die "roborio gcc patch failed"
    xpopd
else
    export APPEND_TOOLLIBDIR=yes
    xpushd "${DOWNLOAD_DIR}/binutils-${V_BIN}"
    patch -p1 -N -s <"${PATCH_DIR}/debian/binutils-${V_BIN}.patch" ||
        die "debian binutils patch failed"
    xpopd
    xpushd "${DOWNLOAD_DIR}/gcc-${V_GCC}"
    patch -p1 -N -s <"${PATCH_DIR}/debian/gcc.patch" ||
        die "debian gcc patch failed"
    xpopd
fi

