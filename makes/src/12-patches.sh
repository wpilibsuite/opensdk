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
    echo "[INFO]: Applied patch ${1}"
}

function patch_project() {
    local proj
    local src
    local ver
    case "$1" in
    bin)
        proj="binutils"
        src="binutils-${V_BIN}"
        ver="${V_BIN}"
        ;;
    gcc)
        proj="gcc"
        src="gcc-${V_GCC}"
        ver="${V_GCC}"
        ;;
    make)
        proj="make"
        src="make-${V_MAKE}"
        ver="${V_MAKE}"
        ;;
    *) die "Unknown config" ;;
    esac

    function patch_loop() {
        xpushd "${1}"
        for _patch in *; do
            if [[ "$_patch" =~ darwin ]] && [ "$WPI_HOST_NAME" != "Mac" ]; then
                # Do not apply macOS specific patches for Windows and Linux
                # builds
                continue
            fi 
            _patch="${PWD}/$_patch"
            xpushd "${DOWNLOAD_DIR}/${src}"
            patch_or_die "$_patch"
            xpopd
        done
        xpopd
    }

    if [ -d "${PATCH_DIR}/${proj}" ]; then
        xpushd "${PATCH_DIR}/${proj}"
        if [ -d "./any" ]; then
            patch_loop "any"
        fi
        if [ -d "./${ver}" ]; then
            patch_loop "${ver}"
        fi
        xpopd
    fi
}

patch_project bin
patch_project gcc
patch_project make

if [ -d "${PATCH_DIR}/targets/consts/${TOOLCHAIN_NAME}" ]; then
    xpushd "${PATCH_DIR}/targets/consts/${TOOLCHAIN_NAME}"
    for _patch in *; do
        _patch="${PWD}/$_patch"
        xpushd "${DOWNLOAD_DIR}/gcc-${V_GCC}"
        patch_or_die "$_patch"
        xpopd
    done
    xpopd
fi
