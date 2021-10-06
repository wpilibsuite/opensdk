#! /usr/bin/env bash

# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh"

rm -rf "${BUILD_DIR}/gcc-build"
mkdir "${BUILD_DIR}/gcc-build"

CONFIGURE_GCC=(
    "${CONFIGURE_COMMON[@]}"
    "--with-cpu=${TARGET_CPU}"
    "--with-fpu=${TARGET_FPU}"
    "--with-arch=${TARGET_ARCH}"
    "--with-float=${TARGET_FLOAT}"
    "--with-specs=${TARGET_SPECS}"
    "--enable-poison-system-directories"
    "--enable-threads=posix"
    "--enable-shared"
    "--with-gcc-major-version-only"
    "--enable-linker-build-id"
    "--enable-__cxa_atexit" # Should be enabled on glibc devices
    "--libdir=${SYSROOT_PATH}/usr/lib"
    "--with-gxx-include-dir=${SYSROOT_PATH}/usr/include/c++/${V_GCC/.*/}"
)

if [ "${WPI_HOST_NAME}" = "Windows" ]; then
    CONFIGURE_GCC+=(
        "--disable-plugin"
    )
else
    # Use system zlib when building target code on a *nix enviorment
    CONFIGURE_GCC+=(
        "--with-system-zlib"
        "--enable-default-pie"
        "--enable-plugin"
    )
fi

if [ "${TARGET_DISTRO}" = "roborio" ]; then
    # Pulled by running gcc -v on target device
    CONFIGURE_GCC+=(
        "--enable-languages=c,c++,fortran"
        "--disable-libmudflap"
        "--enable-c99"
        "--enable-symvers=gnu"
        "--enable-long-long"
        "--enable-libstdcxx-pch"
        "--enable-lto"
        "--enable-libssp"
        "--enable-libitm"
        "--enable-initfini-array"
        "--with-linker-hash-style=gnu"
        "--with-gnu-ld"
        "--with-ppl=no"
        "--with-cloog=no"
        "--with-isl=no"
        "--without-long-double-128"
    )
else
    # Pulled by running gcc -v on target devices
    CONFIGURE_GCC+=(
        # Debian specific flags
        "--enable-languages=c,c++"
        "--enable-clocal=gnu"
        "--without-included-gettext"
        "--enable-libstdcxx-debug"
        "--enable-libstdcxx-time=yes"
        "--with-default-libstdcxx-abi=new"
        "--enable-gnu-unique-object"
    )
    case "${TARGET_PORT}" in
    # Debian Port specific flags
    amd64) CONFIGURE_GCC+=(
        "--disable-vtable-verify"
        "--disable-multilib"
        "--enable-libmpx"
    ) ;;
    armhf) CONFIGURE_GCC+=(
        "--disable-libitm"
        "--disable-libquadmath"
        "--disable-libquadmath-support"
    ) ;;
    arm64) CONFIGURE_GCC+=(
        "--disable-libquadmath"
        "--disable-libquadmath-support"
    ) ;;
    esac
fi

function _make_multi() {
    function _make() {
        local msg
        msg="$1"
        shift
        make -j"$JOBS" "${@}" || die "$msg"
    }

    function _make_installer() {
        local msg
        msg="$1"
        shift
        make \
            DESTDIR="${BUILD_DIR}/gcc-install" \
            "${@}" || die "$msg"
    }
    _make "$1" "all-$2"
    _make_installer "$1" "install-$2"
}

xpushd "${BUILD_DIR}/gcc-build"
"$DOWNLOAD_DIR/gcc-${V_GCC}/configure" \
    "${CONFIGURE_GCC[@]}" ||
    die "gcc configure failed"
# Build the core compiler without libraries
_make_multi "gcc build failed" gcc

if [ "${PREBUILD_CANADIAN}" = "true" ]; then
    # We don't need support libraries for the first stage
    exit 0
fi

case "${TARGET_DISTRO}" in
roborio)
    _make_multi "gcc libgfortran failed" target-libgfortran
    _make_multi "gcc libsanitizer failed" target-libsanitizer
    if [ "${TARGET_LIB_REBUILD}" = "true" ]; then
        # Only rebuild what came from the original sysroot
        _make_multi "gcc libgcc failed" target-libgcc
        _make_multi "gcc libatomic failed" target-libatomic
        _make_multi "gcc libstdc++ failed" target-libstdc++-v3
    fi
    ;;
*) ;; # No current need to build support libraries for debian targets
esac
xpopd
