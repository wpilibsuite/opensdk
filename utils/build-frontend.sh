#! /usr/bin/env bash

# Change directory to project base
cd "$(dirname "$0")/.." || exit

set -a
ROOT_DIR="${PWD}"
# shellcheck source=../scripts/setup.sh
source "$ROOT_DIR/scripts/setup.sh"
set +a

# Change ulimit to avoid issues with large files
if [ "$WPI_HOST_NAME" = "Windows" ]; then
    ulimit -n 97816
fi

die() {
    echo "[FATAL]: $1" >&2
    exit 1
}

# Check if system is a x86_64 system
if [ "$(uname -m)" != "x86_64" ]; then
    die "Toolchain builds require x86 build machines"
fi

# TODO: Now that the libraries are built in linux,
# could the build work in windows?
if [ "${PREBUILD_CANADIAN}" = "true" ]; then
    case "$(uname)" in
    Linux) _os="linux" ;;
    Darwin) _os="macos" ;;
    *)
        die "Unsupported build system"
        ;;
    esac
    # Recursivly build to setup host to help the canadian build
    CANADIAN_STAGE_ONE=true PREBUILD_CANADIAN=false bash \
        "$0" "hosts/${_os}_x86_64.env" "$2" "$3" || exit
    unset _os
    if ! [ -x "/opt/frc/bin/${TARGET_TUPLE}-gcc" ]; then
        echo "[ERROR]: /opt/frc/bin/${TARGET_TUPLE} missing"
        bash
        exit 1
    elif ! [[ "$(file "/opt/frc/bin/${TARGET_TUPLE}-gcc")" =~ x86[-_]64 ]]; then
        echo "[ERROR]: /opt/frc/bin/${TARGET_TUPLE} is built incorrectly"
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
    task/20-binutils \
    task/30-gcc-configure \
    task/31-gcc-frontend \
    task/40-expat \
    task/41-gdb \
    task/50-frcmake \
    task/99-tree

if [ "$CANADIAN_STAGE_ONE" = "true" ]; then
    sudo mkdir -p /opt/frc
    rsync -aEL \
        "${BUILD_DIR}/sysroot-install/" \
        "${BUILD_DIR}/binutils-install/opt/frc/" \
        "${BUILD_DIR}/gcc-install/opt/frc/" \
        /opt/frc/
    exit 0
fi

${MAKE} pkg
