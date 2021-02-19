#! /usr/bin/env bash

function import-pgp-keys() {
    for KEY in "$@"
    do
        # Dont Attempt import if it already exists
        gpg --list-key "0x$KEY" > /dev/null 2>&1 && continue

        # Enfoce https fetch
        wget -nv -O - "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x${KEY}" | \
            gpg --import || { echo "Could not import 0x${KEY} into gpg"; exit 1; }
    done
}

function basic-download() {
    FILE="${1/*\//}"
    [ -r "$FILE" ] && return
    wget -nc -nv "$1" || return
}

function signed() {
    BASE_FILE=${2/*\//}
    basic-download "$2" || { echo "Could Not Download $BASE_FILE"; exit 1; }
    basic-download "$2.$1" || return 0 # Signature missing, skip
    gpg --verify "$BASE_FILE.$1" || { echo "Cannot Verify $BASE_FILE Download"; exit 1; }
    rm "$BASE_FILE.$1" || { echo "Could Not Cleanup Download for $BASE_FILE"; exit 1; }
}

function signed-ni() {
    BASE_FILE=${1/*\//}
    PACKAGE=${BASE_FILE//_*/}
    BLOCK=$(sed -e '/Package: '"$PACKAGE"'$/,/Priority/!d' < Packages) || { echo "Could Not Open Packages"; return; }
    SHA=$(echo "$BLOCK" | grep 'SHA256' | sed -e 's/.*: //g')
    basic-download "$1" || { echo "Could Not Download $BASE_FILE"; exit 1; }

    # Requires two spaces
    echo "$SHA  $BASE_FILE" | shasum -a 256 -c - || { echo "Cannot Verify $BASE_FILE Download"; exit 1; }
}
