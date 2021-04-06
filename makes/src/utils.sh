#! /usr/bin/env bash

[ "$WPITARGET" = "sysroot" ] && exit 0

cd "$(dirname "$0")"

source "$ROOT_DIR/consts.env"
source "$SCRIPT_DIR/downloads_tools.sh"

pushd "$ROOT_DIR/downloads"
signed sig https://ftp.gnu.org/gnu/binutils/binutils-${V_BIN}.tar.bz2
signed sig https://ftp.gnu.org/gnu/gdb/gdb-${V_GDB}.tar.gz

tar xf binutils-${V_BIN}.tar.bz2
tar xf gdb-${V_GDB}.tar.gz
popd

CORE_ARGS=(
    "--build=$($ROOT_DIR/downloads/binutils-${V_BIN}/config.guess)"
    "--host=${WPIHOSTTARGET}"
    "--target=${TARGET_TUPLE}"
    "--prefix=${WPIPREFIX}"
    "--program-prefix=${TARGET_PREFIX}"
    "--enable-plugins"
    "--disable-nls"
    "--enable-lto"
    "--disable-werror"
    "--with-sysroot=${WPIPREFIX}/${TARGET_TUPLE}"
    "--with-build-sysroot=${WPIPREFIX}/${TARGET_TUPLE}"
    "--disable-dependency-tracking"
    "--with-pkgversion=${K_VENDOR_ID}"
)

mkdir -p "${BUILD_DIR}"
pushd "$BUILD_DIR/"
rm -rf {binutils,gdb}-{build,install}
mkdir -p {binutils,gdb}-{build,install}

pushd "binutils-build/"
"$ROOT_DIR/downloads/binutils-${V_BIN}/configure" \
    "${CORE_ARGS[@]}" \
    --enable-poison-system-directories ||
    exit
make -j"$JOBS" || exit
DESTDIR=$PWD/../binutils-install make install install-strip || exit
popd

if [ "$CANADIAN_STAGE_ONE" = "true" ]; then
    exit 0
fi

pushd "gdb-build/"
CFLAGS="$GDB_CFLAGS"
CXXFLAGS="$GDB_CXXFLAGS"
export {C,CXX}FLAGS
"$ROOT_DIR/downloads/gdb-${V_GDB}/configure" \
    "${CORE_ARGS[@]}" \
    --without-expat \
    --disable-debug || exit
make -j"$JOBS" || exit
DESTDIR=$PWD/../gdb-install make install install-gdb || exit
popd

popd
