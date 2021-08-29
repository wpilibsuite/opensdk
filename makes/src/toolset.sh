#! /usr/bin/env bash
# shellcheck disable=SC2010

# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh"

# If these fail, then others are bad aswell
[ "${V_BIN:-fail}" != fail ] || die "V_BIN"
[ "${V_GDB:-fail}" != fail ] || die "V_GDB"
[ "${V_GCC:-fail}" != fail ] || die "V_GCC"
[ "${DOWNLOAD_DIR:-fail}" != fail ] || die "Download Dir"
[ "${REPACK_DIR:-fail}" != fail ] || die "Repack Dir"

rm -rf "${DOWNLOAD_DIR}"
mkdir -p "${DOWNLOAD_DIR}"

xpushd "${DOWNLOAD_DIR}"
wget -nc -nv "https://ftp.gnu.org/gnu/binutils/binutils-${V_BIN}.tar.gz" ||
    die "binutils download failed"
wget -nc -nv "https://ftp.gnu.org/gnu/gcc/gcc-${V_GCC}/gcc-${V_GCC}.tar.gz" ||
    die "gcc download failed"
wget -nc -nv "https://ftp.gnu.org/gnu/gdb/gdb-${V_GDB}.tar.gz" ||
    die "gcc download failed"
tar xf "binutils-${V_BIN}.tar.gz" || die "binutils extract failed"
tar xf "gcc-${V_GCC}.tar.gz" || die "gcc extract failed"
tar xf "gdb-${V_GDB}.tar.gz" || die "gdb extract failed"
xpushd "gcc-${V_GCC}"
./contrib/download_prerequisites || die "gcc prerequisite fetching failed"
if ls -l "${PATCH_DIR}/" | grep -q "gcc-${V_GCC//.*/}"; then
    for file in "${PATCH_DIR}"/gcc-"${V_GCC//.*/}"_*.patch; do
        patch -p1 -N -s <"$file"
    done
fi
xpopd
if [ "${TARGET_DISTRO}" = "roborio" ]; then
    xpushd "gcc-${V_GCC}"
    patch -p1 -N -s <"${PATCH_DIR}/roborio/gcc.patch" ||
        die "roborio gcc patch failed"
    xpopd
else
    export APPEND_TOOLLIBDIR=yes
    xpushd "binutils-${V_BIN}"
    patch -p1 -N -s <"${PATCH_DIR}/debian/binutils-${V_BIN}.patch" ||
        die "debian binutils patch failed"
    xpopd
    xpushd "gcc-${V_GCC}"
    patch -p1 -N -s <"${PATCH_DIR}/debian/gcc.patch" ||
        die "debian gcc patch failed"
    xpopd
fi
xpopd

xpushd "${BUILD_DIR}"
PATH="${WPIPREFIX}/bin:${PATH}"
PATH="${PWD}/binutils-install/${WPIPREFIX}/bin:${PATH}"
PATH="${PWD}/gcc-install/${WPIPREFIX}/bin:${PATH}"
PATH="${PWD}/gdb-install/${WPIPREFIX}/bin:${PATH}"
export PATH
[ ! -d "binutils-build" ] || die "unclean enviorment"

mkdir binutils-build binutils-install
mkdir gcc-build gcc-install
mkdir gdb-build gdb-install
xpopd

# "gcc -dumpmachine" is the most portable config
BUILD_TUPLE="$(gcc -dumpmachine)"
HOST_TUPLE="${WPIHOSTTARGET}"
SYSROOT_PATH="${WPIPREFIX}/${TARGET_TUPLE}"
SYSROOT_BUILD_PATH="$BUILD_DIR/sysroot-install/$TARGET_TUPLE"

CONFIGURE_COMMON=(
    "--build=${BUILD_TUPLE}"
    "--host=${HOST_TUPLE}"
    "--target=${TARGET_TUPLE}"
    "--prefix=${WPIPREFIX}"
    "--program-prefix=${TARGET_PREFIX}"
    "--disable-bootstrap"
    "--enable-lto"
    "--disable-nls"
    "--disable-werror"
    "--disable-debug"
    "--with-sysroot=${SYSROOT_PATH}"
    "--with-build-sysroot=${SYSROOT_BUILD_PATH}"
    # "--with-pkgversion='${K_VENDOR_ID}'"
    "--enable-poison-system-directories"
)

if [ "${WPITARGET}" != "Windows" ]; then
    CONFIGURE_COMMON[${#CONFIGURE_COMMON[@]}]="--with-system-zlib"
fi

xpushd "${BUILD_DIR}/binutils-build"
"$DOWNLOAD_DIR/binutils-${V_BIN}/configure" \
    "${CONFIGURE_COMMON[@]}" \
    --enable-ld \
    --enable-deterministic-archives ||
    die "binutils configure failed"
make -j"$JOBS" || die "binutils build failed"
DESTDIR="${BUILD_DIR}/binutils-install" make \
    install || die "binutils install failed"
xpopd

xpushd "${BUILD_DIR}/gcc-build"
"$DOWNLOAD_DIR/gcc-${V_GCC}/configure" \
    "${CONFIGURE_COMMON[@]}" \
    "--with-cpu=${TARGET_CPU}" \
    "--with-fpu=${TARGET_FPU}" \
    "--with-arch=${TARGET_ARCH}" \
    "--with-float=${TARGET_FLOAT}" \
    "--with-specs=${TARGET_SPECS}" \
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

if [ "$CANADIAN_STAGE_ONE" = "true" ]; then
    exit 0
fi

xpushd "${BUILD_DIR}/gdb-build"
"$DOWNLOAD_DIR/gdb-${V_GDB}/configure" \
    "${CONFIGURE_COMMON[@]}" \
    --without-expat ||
    die "gdb configure failed"
make -j"$JOBS" || die "gdb build failed"
DESTDIR="${BUILD_DIR}/gdb-install" make \
    install || die "gdb install failed"
xpopd
