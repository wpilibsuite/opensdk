#! /usr/bin/env bash

# Always ensure proper path
cd "$(dirname "$0")" || exit

set -a
ROOT_DIR="${PWD}"
# shellcheck source=./scripts/setup.sh
source "$ROOT_DIR/scripts/setup.sh"
set +a

if [ "${WPITARGET}" = "Windows" ]; then
    # Recursivly build to setup host to help the canadian build
    CANADIAN_STAGE_ONE=true bash \
        "$0" "hosts/linux_x86_64.env" "$2" "$3" || exit
fi

set -e

# Prep builds
mkdir -p "${DOWNLOAD_DIR}" "${REPACK_DIR}"
pushd "${DOWNLOAD_DIR}"
bash "${TARGET_CFG}/download.sh"
bash "${TARGET_CFG}/repack.sh" "${REPACK_DIR}/"
popd

mkdir -p "${BUILD_DIR}"
MAKE="make -C ${ROOT_DIR}/makes/ M=${BUILD_DIR}"
if [ "$WPITARGET" = "sysroot" ]; then
    ${MAKE} sysroot
else
    ${MAKE} basic
    if [ "$CANADIAN_STAGE_ONE" = "true" ]; then
        exit 0
    fi
fi

if is-mac-codesign; then
    bash scripts/codesign.sh
fi

# Package build for release
${MAKE} pkg
