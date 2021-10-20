#! /usr/bin/bash
# shellcheck disable=SC2010

# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh"

function download_or_die() {
    wget -nc -nv "$1" &>/dev/null ||
        die "Failed to download archive from $1"
}

function download_extract() {
    download_or_die "$1"
    tar xf "${1/*\//}" || die "${1/*\//} extract failed"
}

function update_config_tools() {
    if ! [ -d "${1}" ]; then
        die "Input directory does not exist!"
    fi
    if [ -e "${1}/config.guess" ]; then
        cp "${DOWNLOAD_DIR}/config.guess" "${1}/config.guess"
    fi
    if [ -e "${1}/config.sub" ]; then
        cp "${DOWNLOAD_DIR}/config.sub" "${1}/config.sub"
    fi
}

rm -rf "${DOWNLOAD_DIR}"
mkdir -p "${DOWNLOAD_DIR}"

xpushd "${DOWNLOAD_DIR}"
GNU_MIRROR="https://ftp.gnu.org/gnu"
EXPAT_MIRROR="https://github.com/libexpat/libexpat/releases/download"
SAVANNAH_MIRROR="https://git.savannah.gnu.org/cgit/config.git/plain"
download_extract "${GNU_MIRROR}/binutils/binutils-${V_BIN}.tar.gz"
download_extract "${GNU_MIRROR}/gcc/gcc-${V_GCC}/gcc-${V_GCC}.tar.gz"
download_extract "${GNU_MIRROR}/gdb/gdb-${V_GDB}.tar.gz"
download_extract "${GNU_MIRROR}/make/make-${V_MAKE}.tar.gz"
download_extract "${EXPAT_MIRROR}/R_${V_EXPAT//./_}/expat-${V_EXPAT}.tar.gz"
download_or_die "${SAVANNAH_MIRROR}/config.guess"
download_or_die "${SAVANNAH_MIRROR}/config.sub"

xpushd "gcc-${V_GCC}"
./contrib/download_prerequisites || die "gcc prerequisite fetching failed"
xpopd

update_config_tools "binutils-${V_BIN}"
update_config_tools "gcc-${V_GCC}"
update_config_tools "gcc-${V_GCC}/gmp"
update_config_tools "gcc-${V_GCC}/isl"
update_config_tools "gcc-${V_GCC}/mpc"
update_config_tools "gcc-${V_GCC}/mpfr"
update_config_tools "expat-${V_EXPAT}/conftools"
update_config_tools "gdb-${V_GDB}"
update_config_tools "make-${V_MAKE}"

xpopd
