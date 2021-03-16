#! /usr/bin/env bash

is-mac || return 0

PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
PATH="/usr/local/opt/gnu-tar/libexec/gnubin:$PATH"
export PATH

CC="cc" # XCode
CXX="c++" # XCode
# CPP="cpp-$GCC_VER"
LD="ld" # Apple linker
export CC CXX LD


# MacOS Flags
CFLAGS="-fcommon -arch arm64 -arch x86_64"
CXXFLAGS="-fcommon -arch arm64 -arch x86_64"
LDFLAGS=""

export CFLAGS CXXFLAGS
