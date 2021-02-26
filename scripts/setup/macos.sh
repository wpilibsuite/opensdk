#! /usr/bin/env bash

is-mac && PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
is-mac && PATH="/usr/local/opt/gnu-tar/libexec/gnubin:$PATH"
export PATH

# Clang appears to have issues
# GCC_VER=10
is-mac && CC="clang"
is-mac && CXX="clang++"
is-mac && CPP="clang++"
#is-mac && LD="gcc-${GCC_VER}"
# unset GCC_VER
export CC CXX CPP # LD

# MacOS Flags
is-mac && CFLAGS="-fbracket-depth=512 -fPIC"
is-mac && CXXFLAGS="-fbracket-depth=512 -fPIC"
export CFLAGS CXXFLAGS
