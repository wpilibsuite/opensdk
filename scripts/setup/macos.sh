#! /usr/bin/env bash

is-mac || return 0

WPI_BUILD_TUPLE="$(cc -dumpmachine)"
WPI_BUILD_TUPLE="${WPI_BUILD_TUPLE//darwin[1-9]*/darwin}"
export WPI_BUILD_TUPLE

case "$WPI_HOST_TUPLE" in
arm64-*-darwin | aarch64-*-darwin)
    export WPI_HOST_SDK_MIN=11.0
    ;;
x86_64-*-darwin)
    export WPI_HOST_SDK_MIN=10.9
    ;;
*-*-darwin[1-9]*)
    echo "[ERROR] Do not use versioned darwin GNU tuples"
    exit 1
    ;;
*) ;;
esac

MACOSX_DEPLOYMENT_TARGET="${WPI_HOST_SDK_MIN}"
CFLAGS="${CFLAGS} -fcommon"
CXXFLAGS="${CXXFLAGS} -fcommon"
export CFLAGS CXXFLAGS MACOSX_DEPLOYMENT_TARGET
