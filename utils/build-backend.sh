#! /usr/bin/env bash

# Change directory to project base
cd "$(dirname "$0")/.." || exit

set -a
ROOT_DIR="${PWD}"
# shellcheck source=../scripts/setup.sh
source "$ROOT_DIR/scripts/setup.sh"
# shellcheck source=../scripts/setup_opensysroot.sh
source "$ROOT_DIR/scripts/setup_opensysroot.sh"
set +a

die() {
    echo "[FATAL]: $1" >&2
    exit 1
}

# Check if system is a Linux x86_64 system
if [ "$(uname)" != "Linux" ] || [ "$(uname -m)" != "x86_64" ]; then
    die "Backend builds require a x86_64 Linux system"
fi

# Set callback on error
function onexit() {
    local -r code="$?"
    echo "[ERROR]: Exiting with code ${code}"
}
trap onexit "err"

mkdir -p "${BUILD_DIR}"
MAKE="make -C ${ROOT_DIR}/makes/ --no-print-directory"

export BUILD_BACKEND=true

${MAKE} \
    task/10-sysroot \
    task/11-sources \
    task/12-patches \
    task/13-normalize \
    task/20-binutils \
    task/40-gcc-configure \
    task/41-gcc-frontend \
    task/42-gcc-backend \
    task/98-package-backend

mkdir -p "${OUTPUT_DIR}"
cp "${BUILD_DIR}/${TARGET_TUPLE}.tar" \
    "${OUTPUT_DIR}/" 

