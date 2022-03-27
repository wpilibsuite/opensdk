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

# Check if system is a Linux or Mac system
if [ "$(uname)" != "Linux" ] && [ "$(uname)" != "Darwin" ]; then
    die "Unsupported build operating system"
fi
# TODO: Now that the libraries are built in linux, could the build work in windows?

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
    task/30-gcc \
    task/40-expat \
    task/41-gdb \
    task/50-frcmake \
    task/99-tree \
    pkg