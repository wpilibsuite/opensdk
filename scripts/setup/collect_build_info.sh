#! /usr/bin/env bash

# shellcheck source=hosts/linux_x86_64.env
source "${HOST_CFG}"
# shellcheck source=consts.env
source "${ROOT_DIR}/consts.env"
# shellcheck source=targets/roborio/info.env
source "${TARGET_CFG}/info.${TARGET_PORT}.env"
if "${STOP_AT_GCC:-false}"; then
    TARGET_PREFIX="$TARGET_TUPLE-"
fi

cat <<EOF
Host System Info
    OS: ${WPITARGET}
    Tuple: ${WPIHOSTTARGET}
    Prefix: ${WPIPREFIX}
Toolchain Info:
    Name: ${TOOLCHAIN_NAME}
    CPU: ${TARGET_CPU}
    Tuple: ${TARGET_TUPLE}
    Prefix: ${TARGET_PREFIX}
EOF

DOWNLOAD_DIR="${ROOT_DIR}/downloads/${TOOLCHAIN_NAME}-${TARGET_PORT}/"
REPACK_DIR="${ROOT_DIR}/repack/${TOOLCHAIN_NAME}-${TARGET_PORT}/"
SCRIPT_DIR="${ROOT_DIR}/scripts/"
PATCH_DIR="${ROOT_DIR}/patches/"
BUILD_DIR="${ROOT_DIR}/build/${TOOLCHAIN_NAME}-${TARGET_PORT}/${WPITARGET}/"

# PATH="$PATH:$BUILD_DIR/binutils-install/${WPIPREFIX}/bin/"
PATH="$PATH:$BUILD_DIR/gcc-install/${WPIPREFIX}/bin/"
