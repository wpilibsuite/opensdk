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
download_extract "https://ftp.gnu.org/gnu/binutils/binutils-${V_BIN}.tar.gz"
download_extract "https://ftp.gnu.org/gnu/gcc/gcc-${V_GCC}/gcc-${V_GCC}.tar.gz"
download_extract "https://ftp.gnu.org/gnu/gdb/gdb-${V_GDB}.tar.gz"
download_extract "https://ftp.gnu.org/gnu/make/make-${V_MAKE}.tar.gz"

xpushd "gcc-${V_GCC}"
./contrib/download_prerequisites || die "gcc prerequisite fetching failed"
xpopd
xpopd
