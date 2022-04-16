#! /usr/bin/env bash

# Change directory to project base
cd "$(dirname "$0")/.." || exit

if [ "$CANADIAN_STAGE_ONE" != true ]; then
    echo "[FATAL]: build-frontend-tiny must not be called directly" >&2
    exit 1
fi

set -a
ROOT_DIR="${PWD}"
# shellcheck source=../scripts/setup.sh
source "$ROOT_DIR/scripts/setup.sh"
set +a

mkdir -p "${BUILD_DIR}"
MAKE="make -C ${ROOT_DIR}/makes/ --no-print-directory"
${MAKE} \
    task/10-sysroot-from-backend \
    task/11-sources \
    task/12-patches \
    task/30-gcc-configure \
    task/31-gcc-frontend 

rsync -aEL \
    "${BUILD_DIR}/gcc-install/" \
    "/"
exit
