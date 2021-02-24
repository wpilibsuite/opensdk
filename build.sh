#! /usr/bin/env bash

# Always ensure proper path
cd "$(dirname "$0")" || exit

ROOT_DIR="${PWD}" && export ROOT_DIR
source "$ROOT_DIR/scripts/setup.sh"
bash ./makes/src/test/test.sh || exit

if [ "${WPITARGET}" = "Windows" ]; then
    # Recursivly build to setup host to help the canadian build
    STOP_AT_GCC=true "${SHELL}" \
        "$0" "hosts/linux_x86_64.env" "$2" || exit
fi

# Prep builds
if [ "$SKIP_PREP" != true ]; then
    mkdir -p "${DOWNLOAD_DIR}" "${REPACK_DIR}"
    pushd "${DOWNLOAD_DIR}" || exit
    bash "${TOOLCHAIN_CFG}/download.sh" || exit
    bash "${TOOLCHAIN_CFG}/repack.sh" "${REPACK_DIR}/" || exit
    popd || exit
fi

mkdir -p "${BUILD_DIR}"
MAKE="make -C ${ROOT_DIR}/makes/ M=${BUILD_DIR}"

set -e

PATH="$PATH:$BUILD_DIR/binutils-install/${WPIPREFIX}/bin/"
PATH="$PATH:$BUILD_DIR/gcc-install/${WPIPREFIX}/bin/"
export PATH
${MAKE} basic
${STOP_AT_GCC:-false} && exit 0 || true
${MAKE} extended

# Package build for release
${MAKE} pkg
