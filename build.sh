#! /usr/bin/env bash

# Always ensure proper path
cd "$(dirname "$0")" || exit

ROOT_DIR="${PWD}"

if [ "$#" != "2" ]; then
    exit 1
fi

RLINK=readlink
[[ "$OSTYPE" == "darwin"* ]] && RLINK="g$RLINK"

HOST_CFG="$($RLINK -f "$1")"
TOOLCHAIN_CFG="$($RLINK -f "$2")"
TOOLCHAIN_NAME="$(basename "$TOOLCHAIN_CFG")"

if ! [ -f "$HOST_CFG" ]; then
    echo "Cannot find selected host at $HOST_CFG"
    exit 1
fi

if ! [ -f "$TOOLCHAIN_CFG/version.env" ]; then
    echo "$TOOLCHAIN_CFG is not a supported toolchain"
    exit 1
fi

# shellcheck source=hosts/linux_x86_64.env
source "${HOST_CFG}"
# shellcheck source=consts.env
source "${ROOT_DIR}/consts.env"
# shellcheck source=targets/roborio/info.env
source "${TOOLCHAIN_CFG}/info.env"

cat << EOF
Host System Info
    OS: ${WPITARGET}
    Tuple: ${WPIHOSTTARGET}
    Prefix: ${WPIPREFIX}
Toolchain Info:
    Name: ${TOOLCHAIN_NAME}
    CPU: ${TARGET_CPU}
    Tuple: ${TARGET_TUPLE}
EOF

if [ "${WPITARGET}" = "Windows" ]; then
    # Recursivly build to setup host to help the canadian build
    STOP_AT_GCC=true "${SHELL}" \
        "$0" "hosts/linux_x86_64.env" "$2" || exit
fi

bash scripts/check_sys_compiler.sh || exit


CC="${WPIHOSTTARGET}-gcc"
CXX="${WPIHOSTTARGET}-g++"
[ "${WPITARGET}" = "Mac" ] && CC=clang
[ "${WPITARGET}" = "Mac" ] && CXX=clang++
export CC CXX

bash ./makes/src/test/test.sh

DOWNLOAD_DIR="${ROOT_DIR}/downloads/${TOOLCHAIN_NAME}/"
REPACK_DIR="${ROOT_DIR}/repack/${TOOLCHAIN_NAME}/"
BUILD_DIR="${ROOT_DIR}/build/${TOOLCHAIN_NAME}/${WPITARGET}/"
JOBS=$(nproc --ignore=1)

export JOBS ROOT_DIR BUILD_DIR REPACK_DIR DOWNLOAD_DIR TOOLCHAIN_NAME

# Prep builds
if [ "$SKIP_PREP" != true ]; then
mkdir -p "${DOWNLOAD_DIR}" "${REPACK_DIR}"
pushd "${DOWNLOAD_DIR}" || exit
    bash "${TOOLCHAIN_CFG}/download.sh" || exit
    bash "${TOOLCHAIN_CFG}/repack.sh" "${REPACK_DIR}/" || exit
popd || exit
fi

mkdir -p "${BUILD_DIR}"
MAKE="make -C ${PWD}/makes/ M=${BUILD_DIR}"

${MAKE} sysroot
[ "${WPITARGET}" = "Windows" ] || ${MAKE} sysroot-install
${MAKE} binutils
export PATH="$PATH:$BUILD_DIR/binutils-install/${WPIPREFIX}/bin/"
[ "${WPITARGET}" = "Windows" ] || ${MAKE} binutils-install
${MAKE} gcc
export PATH="$PATH:$BUILD_DIR/gcc-install/${WPIPREFIX}/bin/"
[ "${WPITARGET}" = "Windows" ] || ${MAKE} gcc-install
${STOP_AT_GCC:-false} && exit

${MAKE} expat gdb tree
${MAKE} tree

if [ "$WPITARGET" != "Windows" ]; then
    ${MAKE} tarpkg
else
    ${MAKE} zip
fi
