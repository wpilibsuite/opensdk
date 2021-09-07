#! /usr/bin/bash
# shellcheck disable=SC2010

# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh"

function patch_or_die() {
    if ! [ -e "${1}" ]; then
        die "${1} does not exist"
    fi
    patch -p1 -N -s <"${1}" ||
        die "patch failed: ${1}"
}

function patch_project() {
    xpushd "${DOWNLOAD_DIR}"
    case "$1" in
        bin) xpushd "binutils-${V_BIN}";;
        gcc) xpushd "gcc-${V_GCC}";;
        make) xpushd "make-${V_MAKE}";;
        *) die "Unknown config";;
    esac
    
    patch_or_die "$2"

    xpopd
    xpopd
}

if ls -l "${PATCH_DIR}/" | grep -q "gcc-${V_GCC//.*/}"; then
    for file in "${PATCH_DIR}"/gcc-"${V_GCC//.*/}"_*.patch; do
        patch_project gcc "$file"
    done
fi

if [ "${WPI_HOST_NAME}" = "Linux" ]; then
    patch_project make "${PATCH_DIR}/hosts/Linux/make.patch"
fi

if [ "${TARGET_DISTRO}" = "roborio" ]; then
    patch_project gcc "${PATCH_DIR}/roborio/gcc.patch"
else
    patch_project bin "${PATCH_DIR}/debian/binutils-${V_BIN}.patch"
    patch_project gcc "${PATCH_DIR}/debian/gcc.patch"
fi
