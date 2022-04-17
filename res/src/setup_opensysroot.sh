#! /bin/sh

K_OPENSYSROOT_MIRROR="https://github.com/RyanHir/opensysroot"
K_OPENSYSROOT_COMMIT=5616ed4

SOURCE="git+${K_OPENSYSROOT_MIRROR}@${K_OPENSYSROOT_COMMIT}"

log="$(mktemp)"

if ! python3 -m pip install "${SOURCE}" > "$log"; then
    cat "$log" 1> /dev/stderr
    rm "$log"
    exit 1
fi

rm "$log"
