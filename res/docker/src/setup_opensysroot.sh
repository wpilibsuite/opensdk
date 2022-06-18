#! /bin/sh

log="$(mktemp)"

if ! python3 -m pip install /opensysroot > "$log"; then
    cat "$log" 1> /dev/stderr
    rm "$log"
    exit 1
fi

rm "$log"
