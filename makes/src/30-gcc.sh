#! /usr/bin/env bash

# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh"

rm -rf "${BUILD_DIR}/gcc-build" "${BUILD_DIR}/gcc-install"
mkdir "${BUILD_DIR}/gcc-build" "${BUILD_DIR}/gcc-install"

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
    "--with-gxx-include-dir=${SYSROOT_PATH}/usr/include/c++/${V_GCC/.*/}"
)

if [ "${WPI_HOST_NAME}" = "Windows" ]; then
    CONFIGURE_GCC+=(
        "--disable-plugin"
    )
else
    if [ "${WPI_HOST_NAME}" = "Linux" ]; then
        # Use system zlib when building target code on Linux
        CONFIGURE_GCC+=("--with-system-zlib")
    fi
    # Don't use zlib on MacOS as it is not ensured that zlib is avaliable
    CONFIGURE_GCC+=(
        "--enable-default-pie"
        "--enable-plugin"
    )
fi

if [ "$TARGET_LIB_REBUILD" = "true" ]; then
    # https://gcc.gnu.org/legacy-ml/gcc-patches/2020-01/msg01652.html
    # A really cool feature to seperate target libraries that only exist in
    # newer releases of GCC.
    gcclib_dir="${WPI_HOST_PREFIX}/${TARGET_TUPLE}/gcclib"
    CONFIGURE_GCC+=(
        "--libdir=${gcclib_dir}"
        "--with-slibdir=${gcclib_dir}"
        "--with-toolexeclibdir=${gcclib_dir}"
    )
else
    CONFIGURE_GCC+=(
        "--libdir=${SYSROOT_PATH}/usr/lib/"
    )
fi

if [ "${TARGET_DISTRO}" = "roborio" ]; then
    # Pulled by running gcc -v on target device
    CONFIGURE_GCC+=(
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

enabled_languages="--enabled-languages=c,c++"

if [ "${TARGET_DISTRO}" = "roborio" ]; then
    enabled_languages+=",fortran"
fi
CONFIGURE_GCC+=(enabled_languages)

function _make_multi() {
    function _make() {
        make -j"$JOBS" "${@}" || return
    }
    function _make_installer() {
        make DESTDIR="${BUILD_DIR}/gcc-install" "${@}" || return
    }

    process_background "Building GCC '$1'" _make "all-$1" ||
        die "GCC build '$1'"
    process_background "Installing GCC '$1'" _make_installer "install-$1" ||
        die "GCC install '$1'"
}

xpushd "${BUILD_DIR}/gcc-build"
process_background "Configuring GCC" \
    "$DOWNLOAD_DIR/gcc-${V_GCC}/configure" \
    "${CONFIGURE_GCC[@]}" ||
    die "gcc configure failed"

# Build the core compiler without libraries
_make_multi gcc

if [ "${BUILD_BACKEND}" = "true" ]; then
    # libgcc is complicated to work with preexisting artifacts
    # so we just rebuild the runtime for all platforms.
    TASKS=(target-libgcc)
    if [ "${TARGET_DISTRO}" = "roborio" ]; then
        TASKS+=(
            target-libgfortran
            target-libsanitizer
        )
        if [ "${TARGET_LIB_REBUILD}" = "true" ]; then
            TASKS+=(
                target-libatomic
                target-libstdc++-v3
            )
        fi
    fi
    for task in "${TASKS[@]}"; do
        _make_multi "$task"
    done
fi

xpopd
