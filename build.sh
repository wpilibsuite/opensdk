#! /usr/bin/env bash

# Always ensure proper path
cd "$(dirname "$0")" || exit

HOST="./hosts/$1.env"
if ! [ -r "$HOST" ]; then
    echo "Cannot find selected host at $HOST"
    exit 1
fi

# shellcheck source=hosts/linux_x86_64.env
source "$HOST"

cat << EOF
Host System Info
    OS: ${WPITARGET}
    Tuple: ${WPIHOSTTARGET}
EOF

${SHELL} scripts/check_sys_compiler.sh || exit

CC="${WPIHOSTTARGET}-gcc"
CXX="${WPIHOSTTARGET}-g++"
export CC CXX
