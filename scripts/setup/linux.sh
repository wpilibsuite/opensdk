#! /usr/bin/env bash

is-linux || return 0

CC="${WPIHOSTTARGET}-gcc"
CXX="${WPIHOSTTARGET}-g++"
CPP="${WPIHOSTTARGET}-cpp"
LD="${WPIHOSTTARGET}-ld"
export CC CXX CPP LD

CFLAGS=""
CXXFLAGS=""
if [ "$WPITARGET" = "Windows" ]; then
    CFLAGS="$CFLAGS -static-libgcc -static-libstdc++"
    CXXFLAGS="$CXXFLAGS -static-libgcc -static-libstdc++"
    LDFLAGS="$LDFLAGS -static-libgcc -static-libstdc++"
fi
export CFLAGS CXXFLAGS LDFLAGS
