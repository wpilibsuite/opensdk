#! /usr/bin/env bash

# Always ensure proper path
cd "$(dirname "$0")" || exit

ROOT_DIR="${PWD}" && export ROOT_DIR
# shellcheck source=./scripts/setup.sh
source "$ROOT_DIR/scripts/setup.sh"

if [ "${WPITARGET}" = "Windows" ]; then
    # Recursivly build to setup host to help the canadian build
    STOP_AT_GCC=true bash \
        "$0" "hosts/linux_x86_64.env" "$2" || exit
fi

# Prep builds
set -e
mkdir -p "${DOWNLOAD_DIR}" "${REPACK_DIR}"
pushd "${DOWNLOAD_DIR}"
bash "${TOOLCHAIN_CFG}/download.sh"
bash "${TOOLCHAIN_CFG}/repack.sh" "${REPACK_DIR}/"
popd

bash "${ROOT_DIR}/scripts/target_utils.sh"

mkdir -p "${BUILD_DIR}"
MAKE="make -C ${ROOT_DIR}/makes/ M=${BUILD_DIR}"
if [ "$WPITARGET" != "sysroot" ]; then
    ${MAKE} basic
    if "${STOP_AT_GCC:-false}"; then
        exit 0
    fi
    ${MAKE} extended
else
    ${MAKE} sysroot
fi

# Package build for release
${MAKE} pkg
