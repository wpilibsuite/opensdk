#! /usr/bin/bash
# shellcheck disable=SC2010

# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh"

function download_or_die() {
    wget -nc -nv "$1" &> /dev/null ||
        die "Failed to download archive from $1"
}

function download_extract() {
    download_or_die "$1"
    tar xf "${1/*\//}" || die "${1/*\//} extract failed"
}

rm -rf "${DOWNLOAD_DIR}"
mkdir -p "${DOWNLOAD_DIR}"

xpushd "${DOWNLOAD_DIR}"
GNU_MIRROR="https://ftp.gnu.org/gnu"
EXPAT_MIRROR="https://github.com/libexpat/libexpat/releases/download"
download_extract "${GNU_MIRROR}/binutils/binutils-${V_BIN}.tar.gz"
download_extract "${GNU_MIRROR}/gcc/gcc-${V_GCC}/gcc-${V_GCC}.tar.gz"
download_extract "${GNU_MIRROR}/gdb/gdb-${V_GDB}.tar.gz"
download_extract "${GNU_MIRROR}/make/make-${V_MAKE}.tar.gz"
download_extract "${EXPAT_MIRROR}/R_${V_EXPAT//./_}/expat-${V_EXPAT}.tar.gz"

xpushd "gcc-${V_GCC}"
./contrib/download_prerequisites || die "gcc prerequisite fetching failed"
xpopd
xpopd
