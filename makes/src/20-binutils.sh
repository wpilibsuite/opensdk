#! /usr/bin/env bash

# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh"

rm -rf "${BUILD_DIR}/binutils-build"
mkdir "${BUILD_DIR}/binutils-build"

if [ "${TARGET_DISTRO}" != "roborio" ]; then
    # Patch is applied with expected env var for
    # debian targets.
    export APPEND_TOOLLIBDIR=yes
fi

CONFIGURE_BINUTILS=(
    "${CONFIGURE_COMMON[@]}"
    "--enable-poison-system-directories"
    "--enable-ld"
    "--enable-deterministic-archives"
)

if [ "$TARGET_LIB_REBUILD" = "true" ]; then
    # https://gcc.gnu.org/legacy-ml/gcc-patches/2020-01/msg01652.html
    # A really cool feature to seperate target libraries that only exist in
    # newer releases of GCC.
    gcclib_dir="${WPI_HOST_PREFIX}/${TARGET_TUPLE}/gcclib"
    CONFIGURE_BINUTILS+=(
        "--libdir=${gcclib_dir}"
        "--with-slibdir=${gcclib_dir}"
        "--with-toolexeclibdir=${gcclib_dir}"
    )
fi

xpushd "${BUILD_DIR}/binutils-build"
process_background "Configuring binutils" \
    "$DOWNLOAD_DIR/binutils-${V_BIN}/configure" \
    "${CONFIGURE_BINUTILS[@]}" ||
    die "binutils configure"
process_background "Building binutils" \
    make -j"$JOBS" || die "binutils build failed"
process_background "Installing binutils" \
    make DESTDIR="${BUILD_DIR}/binutils-install" \
    install || die "binutils install failed"
if [ "${BUILD_BACKEND}" = "true" ]; then
    # GCC needs binutils in prefix path while building
    # the target libraries. Using sudo here is messy but
    # I do not want to spend the time to work around this.
    process_background "Installing binutils as root" \
        sudo make install ||
        die "binutils root install failed"
fi
xpopd
