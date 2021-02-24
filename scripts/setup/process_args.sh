#! /usr/bin/env bash

if [ "$#" != "2" ]; then
    exit 1
fi

HOST_CFG="$(readlink -f "$1")"
TOOLCHAIN_CFG="$(readlink -f "$2")"
TOOLCHAIN_NAME="$(basename "$TOOLCHAIN_CFG")"
export HOST_CFG TOOLCHAIN_CFG TOOLCHAIN_NAME

if ! [ -f "$HOST_CFG" ]; then
    echo "Cannot find selected host at $HOST_CFG"
    exit 1
fi

if ! [ -f "$TOOLCHAIN_CFG/version.env" ]; then
    echo "$TOOLCHAIN_CFG is not a supported toolchain"
    exit 1
fi

