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
STRIP="./bin/${TARGET_PREFIX}strip"

C_CODE='
#include <stdio.h>
int main() {
    puts("Hello World");
    return 0;
}
'

CXX_CODE='
#include <iostream>
int main() {
    struct exception {};
    std::cout << "Hello World" << std::endl;
    try { throw exception{}; }
    catch (exception) {}
    catch (...) {}
    return 0;
}
'

echo "[INFO]: Testing C Compiler"
echo "$C_CODE" | "$CC" -x c -o a.out - || exit

echo "[INFO]: Testing C++ Compiler"
echo "$CXX_CODE" | "$CXX" -x c++ -o a.out - || exit

echo "[INFO]: Testing C sanitizer linkage"
echo "$C_CODE" | "$CC" -x c -o a.out -fsanitize=undefined - || exit

echo "[INFO]: Testing C++ sanitizer linkage"
echo "$CXX_CODE" | "$CXX" -x c++ -o a.out -fsanitize=undefined - || exit

echo "[INFO]: Testing ELF strip"
"${STRIP}" a.out || exit

echo "[INFO]: Logging basic compiler file result"
file a.out || exit

xpopd
rm -r toolchain
xpopd

rm -r "$tmp"
