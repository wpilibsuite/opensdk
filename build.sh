#! /usr/bin/env bash

# Always ensure proper path
cd "$(dirname "$0")" || exit

set -a
ROOT_DIR="${PWD}"
# shellcheck source=./scripts/setup.sh
source "$ROOT_DIR/scripts/setup.sh"
source "$ROOT_DIR/scripts/downloads_tools.sh"
set +a

function onexit() {
    code="$?"
    if [ "${code}" != "0" ]; then
        echo "[ERROR]: Exiting with code ${code}"
    else
        echo "[INFO]: Exiting with code ${code}"
    fi
}
trap onexit "err" "exit"

if [ "${PREBUILD_CANADIAN}" = "true" ]; then
    # Recursivly build to setup host to help the canadian build
    CANADIAN_STAGE_ONE=true \
        PREBUILD_CANADIAN=false bash \
        "$0" "hosts/linux_x86_64.env" "$2" "$3" || exit
fi

set -e

# Prep builds
mkdir -p "${DOWNLOAD_DIR}" "${REPACK_DIR}"
pushd "${DOWNLOAD_DIR}"
signed sig "https://ftp.gnu.org/gnu/gcc/gcc-${V_GCC}/gcc-${V_GCC}.tar.gz"
python3 -m opensysroot \
    "${TARGET_DISTRO}" \
    "${TARGET_PORT}" \
    "${TARGET_DISTRO_RELEASE}" \
    . || exit
mv "./${TARGET_DISTRO}/${TARGET_DISTRO_RELEASE}/${TARGET_PORT}/sysroot/"* \
    "${REPACK_DIR}" || exit
sysroot-package
popd

mkdir -p "${BUILD_DIR}"
MAKE="make -C ${ROOT_DIR}/makes/ M=${BUILD_DIR}"
${MAKE} basic
if [ "$CANADIAN_STAGE_ONE" = "true" ]; then
    exit 0
fi

if is-mac-codesign; then
    bash scripts/codesign.sh
fi

# Package build for release
${MAKE} pkg
