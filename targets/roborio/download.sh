#! /usr/bin/env bash

source "$(dirname "$0")/version.env" || exit
source "${SCRIPT_DIR}/downloads_tools.sh" || exit

signed sig https://ftp.gnu.org/gnu/gcc/gcc-${V_GCC}/gcc-${V_GCC}.tar.gz

PACKAGES=(
    "gcc"
    "libatomic-dev"
    "libc6"
    "libc6-dev"
    "libgcc-s-dev"
    "libgomp-dev"
    "libssp-dev"
    "libstdc++-dev"
    "linux-libc-headers-dev"
    "ncurses-libtinfo-dev"
    "ncurses-terminfo-dev"
)

python3 "${SCRIPT_DIR}/repocli.py" ni main cortexa9-vfpv3 . "${PACKAGES[@]}"
