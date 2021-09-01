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
xpopd
xpopd
