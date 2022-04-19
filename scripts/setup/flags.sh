#! /usr/bin/env bash

if [ "$WPI_HOST_NAME" = "Windows" ]; then
    CFLAGS="$CFLAGS -static-libgcc -static-libstdc++"
    CXXFLAGS="$CXXFLAGS -static-libgcc -static-libstdc++"
    LDFLAGS="$LDFLAGS -static-libgcc -static-libstdc++"
fi
export CFLAGS CXXFLAGS LDFLAGS

# Make-server processes
if [ "$WPI_USE_THREADS" ]; then
    JOBS="$WPI_USE_THREADS"
else
    if [ "$WPI_HOST_NAME" = "Mac" ]; then
        JOBS="$(sysctl -n hw.ncpu)"
    else
        JOBS="$(nproc)"
    fi
    # Allow one empty thread so you can still
    # use the machine as you are compiling.
    JOBS="$(( "$JOBS" - 1 ))"
fi
export JOBS
