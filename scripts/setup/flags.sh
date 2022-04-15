#! /usr/bin/env bash

# Core flags
CFLAGS="$CFLAGS -Os -g0"
CXXFLAGS="$CXXFLAGS -Os -g0"
if [ "$WPI_HOST_NAME" = "Mac" ]; then
    # Clang has a lower bracket depth than what GCC may have
    CFLAGS+=" -fbracket-depth=512 -fcommon"
    CXXFLAGS+=" -fbracket-depth=512 -fcommon"
fi
if [ "$WPI_HOST_NAME" = "Windows" ]; then
    CFLAGS="$CFLAGS -static-libgcc -static-libstdc++"
    CXXFLAGS="$CXXFLAGS -static-libgcc -static-libstdc++"
    LDFLAGS="$LDFLAGS -static-libgcc -static-libstdc++"
fi
export CFLAGS CXXFLAGS LDFLAGS

# Make-server processes
if [ "$WPI_HOST_NAME" = "Mac" ]; then
    JOBS="$(sysctl -n hw.ncpu)"
else
    JOBS="$(nproc)"
fi
if [ "$CI" != "true" ]; then
    # Allow one empty thread so you can still
    # use the machine as you are compiling.
    JOBS="$(( "$JOBS" - 1 ))"
fi
export JOBS
