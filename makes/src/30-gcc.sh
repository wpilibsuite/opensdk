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

if [ "${WPI_HOST_NAME}" != "Windows" ]; then
    # Use system zlib when building target code on a *nix enviorment
    CONFIGURE_GCC+=(
        "--with-system-zlib"
        "--enable-default-pie"
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
        "--enable-languages=c,c++"
        "--enable-clocal=gnu"
        "--without-included-gettext"
        "--enable-libstdcxx-debug"
        "--enable-libstdcxx-time=yes"
        "--with-default-libstdcxx-abi=new"
        "--enable-gnu-unique-object"
        "--enable-plugin"
    )
    case "${TARGET_PORT}" in
    amd64) CONFIGURE_GCC+=(
        "--disable-vtable-verify"
        "--enable-libmpx"
    ) ;;
    armhf) CONFIGURE_GCC+=(
        "--disable-sjlj-exceptions"
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

xpushd "${BUILD_DIR}/gcc-build"
"$DOWNLOAD_DIR/gcc-${V_GCC}/configure" \
    "${CONFIGURE_GCC[@]}" ||
    die "gcc configure failed"

make -j"$JOBS" \
    all-gcc ||
    die "gcc build failed"
DESTDIR=${BUILD_DIR}/gcc-install make \
    install-gcc ||
    die "gcc install failed"
if [ "${TARGET_DISTRO}" = "roborio" ]; then
    make -j"$JOBS" \
        all-target-libgfortran \
        all-target-libsanitizer ||
        die "gcc sanitizer build failed"
    DESTDIR=${BUILD_DIR}/gcc-install make -j"$JOBS" \
        install-target-libgfortran \
        install-target-libsanitizer ||
        die "gcc sanitizer install failed"
fi
xpopd
