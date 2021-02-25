#! /usr/bin/env bash

# shellcheck source=hosts/linux_x86_64.env
source "${HOST_CFG}"
# shellcheck source=consts.env
source "${ROOT_DIR}/consts.env"
# shellcheck source=targets/roborio/info.env
source "${TOOLCHAIN_CFG}/info.env"
export WPITARGET WPIHOSTTARGET WPIPREFIX TOOLCHAIN_NAME TARGET_CPU TARGET_TUPLE

cat <<EOF
Host System Info
    OS: ${WPITARGET}
    Tuple: ${WPIHOSTTARGET}
    Prefix: ${WPIPREFIX}
Toolchain Info:
    Name: ${TOOLCHAIN_NAME}
    CPU: ${TARGET_CPU}
    Tuple: ${TARGET_TUPLE}
EOF

DOWNLOAD_DIR="${ROOT_DIR}/downloads/${TOOLCHAIN_NAME}/"
REPACK_DIR="${ROOT_DIR}/repack/${TOOLCHAIN_NAME}/"
PATCH_DIR="${ROOT_DIR}/patches/"
BUILD_DIR="${ROOT_DIR}/build/${TOOLCHAIN_NAME}/${WPITARGET}/"
JOBS=$(nproc --ignore=1)

PATH="$PATH:$BUILD_DIR/binutils-install/${WPIPREFIX}/bin/"
PATH="$PATH:$BUILD_DIR/gcc-install/${WPIPREFIX}/bin/"

export DOWNLOAD_DIR REPACK_DIR PATCH_DIR BUILD_DIR JOBS PATH
