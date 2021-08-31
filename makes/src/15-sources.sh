#! /usr/bin/bash
# shellcheck disable=SC2010

# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh"

rm -rf "${DOWNLOAD_DIR}"
mkdir -p "${DOWNLOAD_DIR}"

xpushd "${DOWNLOAD_DIR}"
wget -nc -nv "https://ftp.gnu.org/gnu/binutils/binutils-${V_BIN}.tar.gz" ||
    die "binutils download failed"
wget -nc -nv "https://ftp.gnu.org/gnu/gcc/gcc-${V_GCC}/gcc-${V_GCC}.tar.gz" ||
    die "gcc download failed"
wget -nc -nv "https://ftp.gnu.org/gnu/gdb/gdb-${V_GDB}.tar.gz" ||
    die "gdb download failed"
wget -nc -nv "https://ftp.gnu.org/gnu/make/make-${V_MAKE}.tar.gz" ||
    die "make download failed"
tar xf "binutils-${V_BIN}.tar.gz" || die "binutils extract failed"
tar xf "gcc-${V_GCC}.tar.gz" || die "gcc extract failed"
tar xf "gdb-${V_GDB}.tar.gz" || die "gdb extract failed"
tar xf "make-${V_MAKE}.tar.gz" || die "make extract failed"
xpushd "gcc-${V_GCC}"
./contrib/download_prerequisites || die "gcc prerequisite fetching failed"
if ls -l "${PATCH_DIR}/" | grep -q "gcc-${V_GCC//.*/}"; then
    for file in "${PATCH_DIR}"/gcc-"${V_GCC//.*/}"_*.patch; do
        patch -p1 -N -s <"$file"
    done
fi
xpopd

xpushd "make-${V_MAKE}"
patch -p1 -N -s <"${PATCH_DIR}/make.patch" ||
    die "frcmake patch failed"
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
