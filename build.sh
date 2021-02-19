#! /usr/bin/env bash

# Always ensure proper path
cd "$(dirname "$0")" || exit

HOST="${PWD}/hosts/$1.env"
TOOLCHAIN="$2"
TOOLCHAIN_DIR="${PWD}/targets/$TOOLCHAIN/"

if ! [ -r "$HOST" ]; then
    echo "Cannot find selected host at $HOST"
    exit 1
fi

if ! [ -d "$TOOLCHAIN_DIR" ]; then
    echo "$TOOLCHAIN is not a supported toolchain"
    exit 1
fi

# shellcheck source=hosts/linux_x86_64.env
source "$HOST"

cat << EOF
Host System Info
    OS: ${WPITARGET}
    Tuple: ${WPIHOSTTARGET}
Toolchain Info:
    Name: ${TOOLCHAIN}
EOF

${SHELL} scripts/check_sys_compiler.sh || exit

CC="${WPIHOSTTARGET}-gcc"
CXX="${WPIHOSTTARGET}-g++"
export CC CXX

mkdir -p "./downloads" && pushd "./downloads" || exit
    ${SHELL} "${TOOLCHAIN_DIR}/download.sh"
popd || exit
