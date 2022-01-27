#! /bin/sh

MIRROR="https://github.com/RyanHir/opensysroot"
COMMIT=5616ed4

if ! python3 -m pip install "git+${MIRROR}@${COMMIT}" > /tmp/.pylog; then
    cat /tmp/.pylog
    exit 1
fi

rm /tmp/.pylog
