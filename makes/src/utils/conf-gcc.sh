#! /usr/bin/env bash

function gcc_make_multi() {
    function _make() {
        make -j"$JOBS" "${@}" || return
    }
    function _make_installer() {
        make DESTDIR="${BUILD_DIR}/gcc-install" "${@}" || return
    }

    process_background "Building GCC '$1'" _make "all-$1" ||
        die "GCC build '$1'"
    process_background "Installing GCC '$1'" _make_installer "install-strip-$1" ||
        die "GCC install '$1'"
}

CONFIGURE_GCC=(
    "${CONFIGURE_COMMON[@]}"
    "--enable-poison-system-directories"
    "--enable-threads=posix"
    "--enable-shared"
    "--with-gcc-major-version-only"
    "--enable-linker-build-id"
    "--enable-__cxa_atexit" # Should be enabled on glibc devices
    "--with-gxx-include-dir=${SYSROOT_PATH}/usr/include/c++/${V_GCC/.*/}"
)

if [ "$TARGET_ARCH" ]; then
    CONFIGURE_GCC+=("--with-arch=${TARGET_ARCH}")
fi

if [ "$TARGET_CPU" ]; then
    CONFIGURE_GCC+=("--with-cpu=${TARGET_CPU}")
fi

if [ "$TARGET_FLOAT" ]; then
    CONFIGURE_GCC+=("--with-float=${TARGET_FLOAT}")
fi

if [ "$TARGET_FPU" ]; then
    CONFIGURE_GCC+=("--with-fpu=${TARGET_FPU}")
fi

if [ "${TARGET_DISTRO}" = "roborio" ]; then
    # Pulled by running gcc -v on target device
    CONFIGURE_GCC+=(
        "--disable-libmudflap"
        "--enable-c99"
        "--enable-symvers=gnu"
        "--enable-long-long"
        "--enable-libstdcxx-pch"
        "--enable-libssp"
        "--enable-libitm"
        "--enable-initfini-array"
        "--without-long-double-128"
    )
else
    # Pulled by running gcc -v on target devices
    CONFIGURE_GCC+=(
        # Debian specific flags
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

enabled_languages="--enable-languages=c"
if [ "$CANADIAN_STAGE_ONE" = true ]; then
    CONFIGURE_GCC+=(
        "--with-gmp"
        "--with-mpfr"
        "--with-mpc"
        "--with-isl"
    )
else
    enabled_languages+=",c++"
    if [ "${TARGET_DISTRO}" = "roborio" ]; then
        enabled_languages+=",fortran"
    fi
fi
CONFIGURE_GCC+=("$enabled_languages")
