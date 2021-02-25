#! /usr/bin/env bash

# Propogates to any tool that sources this file
set -e

function import-pgp-keys() {
    for KEY in "$@"
    do
        # Dont Attempt import if it already exists
        gpg --list-key "0x$KEY" > /dev/null 2>&1 && continue

        # Enfoce https fetch
        KEYDATA=$(wget -nv -O - "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x${KEY}")
        if ! (echo "$KEYDATA" | gpg --import); then
            echo "Could not import 0x${KEY} into gpg"
            exit 1
        fi
    done
}

PUB_KEYS=(
    3AB00996FC26A641 # gcc
    A328C3A2C3C45C06 # gcc-alt
    C3126D3B4AE55E93 # binutils
    980C197698C3739D # mpfr
    F7D5C9BF765C61E3 # mpc
    F3599FF828C67298 # gmp
    92EDB04BFF325CF3 # gdb
    B00BC66A401A1600 # expat
)

import-pgp-keys "${PUB_KEYS[@]}" || exit

function basic-download() {
    FILE="${1/*\//}"
    [ -r "$FILE" ] && return
    wget -nc -nv "$1" || return
}

function package-confirm() {
    REPO_FILE="$1"
    PACKAGE_FILE="$2"

    PACKAGE="${PACKAGE_FILE//_*/}"
    echo "testing package $PACKAGE"
    BLOCK=$(sed -e '/Package: '"$PACKAGE"'$/,/Priority/!d' < "$REPO_FILE")
    SHA=$(echo "$BLOCK" | grep 'SHA256' | sed -e 's/.*: //g')
    echo "$SHA  $PACKAGE_FILE" | shasum -a 256 -c - || exit
}

function signed() {
    BASE_FILE=${2/*\//}
    basic-download "$2" || exit 1
    basic-download "$2.$1" || return 0 # Signature missing, skip
    gpg --verify "$BASE_FILE.$1" || exit 1
}

function signed-ni() {
    basic-download "$1" || exit
    package-confirm "Packages" "$(basename "$1")" || exit
}
