#! /usr/bin/env bash

# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh"

if [ "${WPITARGET}" != "Windows" ]; then
    # Only on GCC for the time being
    CONFIGURE_COMMON[${#CONFIGURE_COMMON[@]}]="--with-system-zlib"
fi

rm -rf "${BUILD_DIR}/gcc-build"
mkdir "${BUILD_DIR}/gcc-build"

xpushd "${BUILD_DIR}/gcc-build"
"$DOWNLOAD_DIR/gcc-${V_GCC}/configure" \
    "${CONFIGURE_COMMON[@]}" \
    "--with-cpu=${TARGET_CPU}" \
    "--with-fpu=${TARGET_FPU}" \
    "--with-arch=${TARGET_ARCH}" \
    "--with-float=${TARGET_FLOAT}" \
    "--with-specs=${TARGET_SPECS}" \
    "--enable-poison-system-directories" \
    "--enable-threads=posix" \
    "--enable-languages=c,c++,fortran" \
    "--enable-shared" \
    "--enable-__cxa_atexit" \
    "--enable-default-pie" \
    "--disable-libmudflap" \
    "--with-gcc-major-version-only" \
    "--libdir=${SYSROOT_PATH}/usr/lib" \
    "--with-gxx-include-dir=${SYSROOT_PATH}/usr/include/c++/${V_GCC/.*/}" ||
    die "gcc configure failed"

make -j"$JOBS" \
    all-gcc \
    all-target-libgfortran ||
    die "gcc build failed"
DESTDIR=${BUILD_DIR}/gcc-install make \
    install-gcc \
    install-target-libgfortran ||
    die "gcc install failed"
if [ "${TARGET_DISTRO}" = "roborio" ]; then
    make -j"$JOBS" \
        all-target-libsanitizer ||
        die "gcc sanitizer build failed"
    DESTDIR=${BUILD_DIR}/gcc-install make -j"$JOBS" \
        install-target-libsanitizer ||
        die "gcc sanitizer install failed"
fi
xpopd
