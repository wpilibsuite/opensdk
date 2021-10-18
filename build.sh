#! /usr/bin/env bash

# Always ensure proper path
cd "$(dirname "$0")" || exit

set -a
ROOT_DIR="${PWD}"
# shellcheck source=./scripts/setup.sh
source "$ROOT_DIR/scripts/setup.sh"
set +a

if [ "$WPI_HOST_NAME" = "Windows" ]; then
    ulimit -n 97816
fi

function onexit() {
    code="$?"
    local msg
    case "$code" in
    0) msg="INFO" ;;
    *) msg="ERROR" ;;
    esac
    echo "[${msg}]: Exiting with code ${code}"
}
trap onexit "err" "exit"

if [ "${PREBUILD_CANADIAN}" = "true" ]; then
    # Recursivly build to setup host to help the canadian build
    CANADIAN_STAGE_ONE=true \
        PREBUILD_CANADIAN=false bash \
        "$0" "hosts/linux_x86_64.env" "$2" "$3" || exit
    if ! [ -x "/opt/frc/bin/${TARGET_TUPLE}-gcc" ]; then
        echo "[ERROR]: /opt/frc/bin/${TARGET_TUPLE} missing"
        exit 1
    fi
    # TODO: This will break if the build machine is not x86_64
    if ! [[ "$(file "/opt/frc/bin/${TARGET_TUPLE}-gcc")" =~ x86-64 ]]; then
        echo "[ERROR]: /opt/frc/bin/${TARGET_TUPLE} is built incorrectly"
        exit 1
    fi
fi

set -e

# Prep builds
mkdir -p "${DOWNLOAD_DIR}"
pushd "${DOWNLOAD_DIR}"
popd

mkdir -p "${BUILD_DIR}"
MAKE="make -C ${ROOT_DIR}/makes/ M=${BUILD_DIR}"
${MAKE} all
if [ "$CANADIAN_STAGE_ONE" = "true" ]; then
    exit 0
fi

if is-mac-codesign; then
    bash scripts/codesign.sh
fi

# Package build for release
${MAKE} pkg
