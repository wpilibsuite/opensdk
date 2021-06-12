#! /usr/bin/env bash

source "$(dirname "$0")/version.env" || exit
source "${SCRIPT_DIR}/downloads_tools.sh" || exit

signed sig https://ftp.gnu.org/gnu/gcc/gcc-${V_GCC}/gcc-${V_GCC}.tar.gz

PACKAGES=(
    "libgcc-10-dev"
    "libstdc++-10-dev"
    "libatomic1"
    "linux-libc-dev"
)

python3 "${SCRIPT_DIR}/repocli.py" debian bullseye ${TARGET_PORT} . "${PACKAGES[@]}"
