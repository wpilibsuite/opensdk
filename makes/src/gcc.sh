#! /usr/bin/env bash
# shellcheck disable=SC2010

source "${ROOT_DIR}/consts.env"
source "${ROOT_DIR}/targets/${TOOLCHAIN_NAME}/info.env"
source "${ROOT_DIR}/targets/${TOOLCHAIN_NAME}/version.env"

CFLAGS="$GCC_CFLAGS"
CXXFLAGS="$GCC_CXXFLAGS"
export CFLAGS CXXFLAGS

export LDFLAGS_FOR_TARGET="-Wl,-Bsymbolic-functions -Wl,-z,relro"

set -e

rm -rf "${BUILD_DIR}/gcc-${V_GCC}"
echo "Extracting GCC..."
tar xf "${DOWNLOAD_DIR}/gcc-${V_GCC}.tar.gz"

pushd "${BUILD_DIR}/gcc-${V_GCC}/"
./contrib/download_prerequisites
if ls -l "${PATCH_DIR}/" | grep -q "gcc-${V_GCC//.*/}"; then
    for file in "${PATCH_DIR}"/gcc-"${V_GCC//.*/}"_*.patch; do
        patch -p1 -N -s <"$file"
    done
fi
if [ "${TARGET_DISTRO}" != "roborio" ]; then
    patch -p1 -N -s <"${PATCH_DIR}/gcc-debian.patch"
fi
popd

BUILD_TUPLE="$(gcc -dumpmachine)" # Builder
HOST_TUPLE="${WPIHOSTTARGET}"

# No Canadian Build on MacOS
if [ "${WPITARGET}" != Mac ]; then
    # If tuple mismatch then confirm if there is first pass
    if [ "$BUILD_TUPLE" != "$HOST_TUPLE" ]; then
        export PATH="/opt/frc/bin:${PATH}"
        command -v "${WPIHOSTTARGET}-gcc" || exit
        command -v "${TARGET_TUPLE}-gcc" || exit
        unset CC CXX CPP LD
    fi
fi

BUILD_INFO=(
    "--build=${BUILD_TUPLE}"
    "--host=${WPIHOSTTARGET}"
    "--target=${TARGET_TUPLE}"
    "--prefix=${WPIPREFIX}"             # Host directory prefix
    "--program-prefix=${TARGET_PREFIX}" # Host binary prefix
    "--disable-bootstrap"
)
TARGET_INFO=(
    "--with-cpu=${TARGET_CPU}"     # target -mtune
    "--with-fpu=${TARGET_FPU}"     # target -mfpu
    "--with-arch=${TARGET_ARCH}"   # target -march
    "--with-float=${TARGET_FLOAT}" # target -mfloat-abi
    "--with-specs=${TARGET_SPECS}" # default target flags
)
FEATURE_INFO=(
    "--enable-threads=posix"           # Target threading library
    "--enable-languages=c,c++,fortran" # More languages require extra packages
    "--with-pkgversion=GCC for FRC ${V_YEAR}"
    "--enable-shared"
    "--enable-__cxa_atexit"
    "--enable-default-pie"
)

SYSROOT_PATH="${WPIPREFIX}/${TARGET_TUPLE}"
SYSROOT_BUILD_PATH="$BUILD_DIR/sysroot-install/$TARGET_TUPLE"
SYSROOT_INFO=(
    "--with-gcc-major-version-only"
    "--enable-poison-system-directories"
    "--with-sysroot=${SYSROOT_PATH}"
    "--libdir=${SYSROOT_PATH}/usr/lib"
    "--with-gxx-include-dir=${SYSROOT_PATH}/usr/include/c++/${V_GCC/.*/}"
    "--with-build-sysroot=${SYSROOT_BUILD_PATH}"
)

if [ "${WPITARGET}" != "Windows" ]; then
    BUILD_INFO[${#BUILD_INFO[@]}]="--with-system-zlib"
fi

rm -rf "${BUILD_DIR}"/gcc-{build,install}
mkdir -p "${BUILD_DIR}"/gcc-{build,install}
pushd "${BUILD_DIR}/gcc-build"
"${BUILD_DIR}/gcc-${V_GCC}/configure" \
    "${BUILD_INFO[@]}" \
    "${TARGET_INFO[@]}" \
    "${FEATURE_INFO[@]}" \
    "${SYSROOT_INFO[@]}" \
    "${BACKPORT_INFO[@]}" \
    --disable-libmudflap ||
    exit
make -j"$JOBS" \
    all-gcc \
    all-target-libgfortran ||
    exit
DESTDIR=${BUILD_DIR}/gcc-install make \
    install-strip-gcc \
    install-target-libgfortran ||
    exit
popd
