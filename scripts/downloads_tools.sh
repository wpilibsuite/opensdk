#! /usr/bin/env bash

function import-pgp-keys() {
    for KEY in "$@"; do
        echo "[INFO] Importing $KEY into gnupg"
        gpg --keyserver "keyserver.ubuntu.com" --recv-key "$KEY" &>/dev/null
        if [ "$?" != "0" ]; then
            echo "[ERR] Could not import $KEY into gpg"
            return 1
        fi
    done
}

PUB_KEYS=(
    3AB00996FC26A641 # Richard Guenther (gcc)
    A328C3A2C3C45C06 # Jakub Jelinek (gcc)
    13FCEF89DD9E3C4F # Nick Clifton (binutils)
    92EDB04BFF325CF3 # Joel Brobecker (gdb)
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

function signed() {
    BASE_FILE=${2/*\//}
    basic-download "$2" || exit 1
    basic-download "$2.$1" || return 0 # Signature missing, skip
    gpg --verify "$BASE_FILE.$1" || exit 1
}

function sysroot-package() {
    pushd "/tmp" || exit
    echo "download dir ${DOWNLOAD_DIR}"
    rm -rf "${DOWNLOAD_DIR}/sysroot-libc-linux"
    mv "${REPACK_DIR}" "${DOWNLOAD_DIR}/sysroot-libc-linux"
    mkdir "${REPACK_DIR}"
    pushd "${DOWNLOAD_DIR}" || exit
    tar cjf sysroot-libc-linux.tar.bz2 sysroot-libc-linux --owner=0 --group=0
    popd || exit
    popd || exit
}
