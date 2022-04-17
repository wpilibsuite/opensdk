#! /usr/bin/env bash

# Change directory to project base
cd "$(dirname "$0")/.." || exit

set -a
ROOT_DIR="${PWD}"
# shellcheck source=../scripts/setup.sh
source "$ROOT_DIR/scripts/setup.sh"
set +a

die() {
    echo "[FATAL]: $1" >&2
    exit 1
}

if [ "${WPI_HOST_CANADIAN}" = "true" ]; then
    # Check if system is a x86_64 system
    if [ "$(uname -m)" != "x86_64" ]; then
        die "Currently canadian builds require a x86_64 build system"
    fi

    case "$(uname)" in
    Linux) _os="linux" ;;
    Darwin) _os="macos" ;;
    *)
        die "Unsupported build system"
        ;;
    esac
    # Recursivly build to setup host to help the canadian build
    CANADIAN_STAGE_ONE=true WPI_HOST_CANADIAN=false bash \
        "utils/build-frontend-tiny.sh" \
        "hosts/${_os}_x86_64.env" "$2" "$3" || exit
    unset _os
    if ! [ -x "/tmp/frc/bin/${TARGET_TUPLE}-gcc" ]; then
        echo "[ERROR]: /tmp/frc/bin/${TARGET_TUPLE} missing"
        bash
        exit 1
    elif ! [[ "$(file "/tmp/frc/bin/${TARGET_TUPLE}-gcc")" =~ x86[-_]64 ]]; then
        echo "[ERROR]: /tmp/frc/bin/${TARGET_TUPLE} is built incorrectly"
        exit 1
    fi
fi

# Set callback on error
function onexit() {
    local -r code="$?"
    echo "[ERROR]: Exiting with code ${code}"
}
trap onexit "err"

mkdir -p "${BUILD_DIR}"
MAKE="make -C ${ROOT_DIR}/makes/ --no-print-directory"
${MAKE} \
    task/10-sysroot-from-backend \
    task/11-sources \
    task/12-patches \
    task/30-binutils \
    task/20-expat \
    task/40-gcc-configure \
    task/41-gcc-frontend \
    task/50-gdb \
    task/51-frcmake \
    task/99-tree

${MAKE} pkg
