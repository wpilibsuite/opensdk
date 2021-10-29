#! /bin/sh

MIRROR="https://github.com/RyanHir/opensysroot"
COMMIT=feb6778

if ! python3 -m pip install "git+${MIRROR}@${COMMIT}" > /tmp/.pylog; then
    cat /tmp/.pylog
    exit 1
fi

rm /tmp/.pylog
