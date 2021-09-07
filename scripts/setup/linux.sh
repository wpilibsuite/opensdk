#! /usr/bin/env bash

is-linux || return 0

CFLAGS=""
CXXFLAGS=""
if [ "$WPI_HOST_NAME" = "Windows" ]; then
    CFLAGS="$CFLAGS -static-libgcc -static-libstdc++"
    CXXFLAGS="$CXXFLAGS -static-libgcc -static-libstdc++"
    LDFLAGS="$LDFLAGS -static-libgcc -static-libstdc++"
fi
export CFLAGS CXXFLAGS LDFLAGS
