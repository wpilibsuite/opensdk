#! /bin/sh

_MACHINE_NAME="$(uname)"
_MACHINE_ARCH="$(uname -m)"

if [ "$_MACHINE_NAME" = "Darwin" ]; then
    echo "macos_${_MACHINE_ARCH}"
elif [ "$_MACHINE_NAME" = "Linux" ]; then
    echo "linux_${_MACHINE_ARCH}"
else
    echo "Unknown host: $_MACHINE_NAME" >&2
    exit 1
fi
