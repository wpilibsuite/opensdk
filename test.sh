#! /usr/bin/env bash

# Always ensure proper path
cd "$(dirname "$0")" || exit

ROOT_DIR="${PWD}" && export ROOT_DIR
TEST_SYS_GCC=false && export TEST_SYS_GCC
# shellcheck source=./scripts/setup.sh
source "$ROOT_DIR/scripts/setup.sh"

MAKE="make -C ${ROOT_DIR}/makes/ M=${BUILD_DIR}"

ARCHIVE_NAME=$(${MAKE} --no-print-directory print-pkg)
if [ ! -f "$ROOT_DIR/$ARCHIVE_NAME" ]; then
    echo "[ERR] $ARCHIVE_NAME not found in base of project"
    exit 1
fi

pushd /tmp/
mkdir -p toolchain
pushd toolchain
tar xf "$ROOT_DIR/$ARCHIVE_NAME"
cd "${TOOLCHAIN_NAME}"
cat << EOF > hello.c
int main() {
    return 0;
}
EOF
"./bin/${TARGET_TUPLE}-gcc" hello.c -o a.out || exit
file a.out
"./bin/${TARGET_TUPLE}-g++" hello.c -o a.out || exit
file a.out

mkdir build/
# Tests to see if cmake-toolchain.cmake works
cat << EOF > CMakeLists.txt
cmake_minimum_required(VERSION 3.1)
project(example)
add_executable(hello hello.c)
EOF

pushd build/
# Test CMake with Unix Makefiles
cmake -DCMAKE_TOOLCHAIN_FILE=../cmake-toolchain.cmake ..
make
file hello
popd

popd
rm -r toolchain
popd
