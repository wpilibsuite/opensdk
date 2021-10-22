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
    local -r code="$?"
    echo "[ERROR]: Exiting with code ${code}"
}

if [ "${PREBUILD_CANADIAN}" = "true" ]; then
    if [ "$(uname -m)" != "x86_64" ]; then
        echo "[ERROR]: Canadian builds require x86 build machines"
        exit 1
    fi
    case "$(uname)" in
    Linux) _os="linux" ;;
    Darwin) _os="macos" ;;
    *)
        echo "[ERROR]: Unsupported build system"
        exit 1
        ;;
    esac
    # Recursivly build to setup host to help the canadian build
    CANADIAN_STAGE_ONE=true PREBUILD_CANADIAN=false bash \
        "$0" "hosts/${_os}_x86_64.env" "$2" "$3" || exit
    unset _os
    if ! [ -x "/opt/frc/bin/${TARGET_TUPLE}-gcc" ]; then
        echo "[ERROR]: /opt/frc/bin/${TARGET_TUPLE} missing"
        exit 1
    elif ! [[ "$(file "/opt/frc/bin/${TARGET_TUPLE}-gcc")" =~ x86-64 ]]; then
        echo "[ERROR]: /opt/frc/bin/${TARGET_TUPLE} is built incorrectly"
        exit 1
    fi
fi

set -e

# Prep builds
mkdir -p "${DOWNLOAD_DIR}"
pushd "${DOWNLOAD_DIR}"
popd

trap onexit "err" "exit"

mkdir -p "${BUILD_DIR}"
MAKE="make -C ${ROOT_DIR}/makes/ M=${BUILD_DIR} --no-print-directory"
${MAKE} all
if [ "$CANADIAN_STAGE_ONE" = "true" ]; then
    exit 0
fi

if is-mac-codesign; then
    bash scripts/codesign.sh
fi

# Package build for release
${MAKE} pkg

trap - "err" "exit"
