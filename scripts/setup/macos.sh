#! /usr/bin/env bash

# Do Not Continue if Linux
is-linux && return 0

PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
PATH="/usr/local/opt/gnu-tar/libexec/gnubin:$PATH"
export PATH

# Clang appears to have issues
GCC_VER=10
CC="gcc-${GCC_VER}"
CXX="g++-${GCC_VER}"
CPP="cpp-${GCC_VER}"
LD="gcc-${GCC_VER}"
unset GCC_VER
export CC CXX CPP LD

# MacOS Flags
CFLAGS="-fbracket-depth=512 -fPIC"
CXXFLAGS="-fbracket-depth=512 -fPIC"
export CFLAGS CXXFLAGS
