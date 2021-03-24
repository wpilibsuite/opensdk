#! /usr/bin/env bash

function import-pgp-keys() {
    for KEY in "$@"; do
        # Dont Attempt import if it already exists
        gpg --list-key "0x$KEY" >/dev/null 2>&1 && continue

        echo "[INFO] Importing $KEY into gnupg"
        gpg --keyserver keyserver.ubuntu.com --recv-key "$KEY" &> /dev/null
        if [ "$?" != "0" ]; then
            echo "[ERR] Could not import 0x${KEY} into gpg"
            return 1
        fi
    done
}

PUB_KEYS=(
    3AB00996FC26A641 # gcc
    A328C3A2C3C45C06 # gcc-alt
    C3126D3B4AE55E93 # binutils
    13FCEF89DD9E3C4F # binutils-alt
    92EDB04BFF325CF3 # gdb
)

import-pgp-keys "${PUB_KEYS[@]}" || return

function basic-download() {
    FILE="${1/*\//}"
    [ -r "$FILE" ] && return
    echo "[INFO] Downloading $FILE"
    if ! wget -nc -nv "$1"; then
        echo "[ERR] Failed to download $FILE"
        return 1
    fi
}

function package-debian() {
    REPOS=(
        "http://ports.ubuntu.com/pool/main/"
        "http://ports.ubuntu.com/pool/universe/"
        "http://ftp.debian.org/debian/pool/main/"
        "http://archive.raspbian.org/raspbian/pool/main/"
    )
    SUB_URL="$1"
    FILE="${SUB_URL//*\/}"
    PACKAGE="${FILE//_*}"
    if [ -r "$FILE" ]; then
        echo "[INFO] '$PACKAGE' is already downloaded"
        return 0
    fi
    for repo in "${REPOS[@]}"; do
        echo "[INFO] Looking for '$PACKAGE' in '$repo'"
        URL="$repo/$SUB_URL"
        basic-download "$URL" && return
        echo "[INFO] '$PACKAGE' is not in $repo"
    done
    echo "[ERR] Cannot find '${FILE}' in any repos"
    return 1
}

function package-confirm() {
    REPO_FILE="$1"
    PACKAGE_FILE="$2"

    PACKAGE="${PACKAGE_FILE//_*/}"
    echo "testing package $PACKAGE"
    BLOCK=$(sed -e '/Package: '"$PACKAGE"'$/,/Priority/!d' <"$REPO_FILE")
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
