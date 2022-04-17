#! /usr/bin/env bash

# shellcheck source=hosts/linux_x86_64.env
source "${HOST_CFG}"
# shellcheck source=consts.env
source "${ROOT_DIR}/consts.env"
# shellcheck source=targets/roborio/info.env
source "${TARGET_CFG}/info.${TARGET_PORT}.env"
source "${TARGET_CFG}/info.env"
source "${TARGET_CFG}/version.env"

if [ "${CANADIAN_STAGE_ONE}" = "true" ]; then
    export TARGET_PREFIX="$TARGET_TUPLE-"
fi

WPI_BUILD_TUPLE="$(cc -dumpmachine | sed 's/darwin.*/darwin/g')"

cat <<EOF
Build System Info:
    Tuple: ${WPI_BUILD_TUPLE}
Host System Info:
    Tuple: ${WPI_HOST_TUPLE}
Toolchain Info:
    Name: ${TOOLCHAIN_NAME}
    CPU: ${TARGET_CPU}
    Tuple: ${TARGET_TUPLE}
    Prefix: ${TARGET_PREFIX}
EOF

DOWNLOAD_DIR="${ROOT_DIR}/downloads/${TOOLCHAIN_NAME}-${TARGET_PORT}"
OUTPUT_DIR="${ROOT_DIR}/output"
SCRIPT_DIR="${ROOT_DIR}/scripts"
PATCH_DIR="${ROOT_DIR}/patches"
BUILD_DIR="${ROOT_DIR}/build/${TOOLCHAIN_NAME}-${TARGET_PORT}/${WPI_HOST_TUPLE}"

PATH="$PATH:$BUILD_DIR/gcc-install/${WPI_HOST_PREFIX}/bin/"
export WPI_BUILD_TUPLE DOWNLOAD_DIR OUTPUT_DIR SCRIPT_DIR PATCH_DIR PATH
