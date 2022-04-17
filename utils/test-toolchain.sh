#! /usr/bin/env bash

# Always ensure proper path
cd "$(dirname "$0")/.." || exit

die() {
    echo "[FATAL]: $1" >&2
    exit 1
}

xcd() {
    cd "$1" >/dev/null || die "cd failed"
}

xpushd() {
    pushd "$1" >/dev/null || die "pushd failed: $1"
}

xpopd() {
    popd >/dev/null || die "popd failed"
}

ROOT_DIR="${PWD}" && export ROOT_DIR
TEST_SYS_GCC=false && export TEST_SYS_GCC
TEST_DIR="${ROOT_DIR}/utils/test"
# shellcheck source=./../scripts/setup.sh
source "$ROOT_DIR/scripts/setup.sh"

MAKE="make -C ${ROOT_DIR}/makes/ --no-print-directory"

ARCHIVE_NAME=$(${MAKE} print-pkg)
if [ ! -f "$ROOT_DIR/output/$ARCHIVE_NAME" ]; then
    echo "[ERR] $ARCHIVE_NAME not found in output directory"
    exit 1
fi

tmp="$(mktemp -d)"
xpushd "${tmp}"

mkdir -p toolchain
xpushd toolchain
tar xf "$ROOT_DIR/output/$ARCHIVE_NAME"
xcd "${TOOLCHAIN_NAME}"

CC="./bin/${TARGET_PREFIX}gcc"
CXX="./bin/${TARGET_PREFIX}g++"
GFORTRAN="./bin/${TARGET_PREFIX}gfortran"
STRIP="./bin/${TARGET_PREFIX}strip"

MACHINE="$("${CC}" -dumpmachine)"
VERSION="$("${CC}" -dumpversion)"

echo "[INFO]: Compiler Target: ${MACHINE}"
echo "[INFO]: Compiler Version: ${VERSION}"

echo "[INFO]: Testing C Compiler"
"$CC" "${TEST_DIR}/hello.c" -o a.out || exit
echo "[INFO]: Testing C Compiler with libasan"
"$CC" "${TEST_DIR}/hello.c" -o /dev/null -fsanitize=address || exit
echo "[INFO]: Testing C Compiler with libubsan"
"$CC" "${TEST_DIR}/hello.c" -o /dev/null -fsanitize=undefined || exit

if [ "${TARGET_ENABLE_CXX}" = "true" ]; then
    echo "[INFO]: Testing C++ Compiler"
    "$CXX" "${TEST_DIR}/hello.cpp"  -o /dev/null || exit
    echo "[INFO]: Testing C++ Compiler with libasan"
    "$CXX" "${TEST_DIR}/hello.cpp"  -o /dev/null -fsanitize=address || exit
    echo "[INFO]: Testing C++ Compiler with libubsan"
    "$CXX" "${TEST_DIR}/hello.cpp"  -o /dev/null -fsanitize=undefined || exit
fi

if [ "${TARGET_ENABLE_FORTRAN}" = "true" ]; then
    echo "[INFO]: Testing Fortran Compiler"
    "$GFORTRAN" "${TEST_DIR}/hello.f95" -o /dev/null || exit
    echo "[INFO]: Testing Fortran Compiler with libasan"
    "$GFORTRAN" "${TEST_DIR}/hello.f95" -o /dev/null -fsanitize=address || exit
    echo "[INFO]: Testing Fortran Compiler with libubsan"
    "$GFORTRAN" "${TEST_DIR}/hello.f95" -o /dev/null -fsanitize=undefined || exit
fi

echo "[INFO]: Testing ELF strip"
"${STRIP}" a.out || exit

echo "[INFO]: Logging basic compiler file result"
file a.out || exit

xpopd
rm -r toolchain
xpopd

rm -r "$tmp"
