#! /usr/bin/env bash

is-mac && PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
is-mac && PATH="/usr/local/opt/gnu-tar/libexec/gnubin:$PATH"
export PATH

# Clang appears to have issues
GCC_VER=10
is-mac && CC="gcc-${GCC_VER}"
is-mac && CXX="g++-${GCC_VER}"
is-mac && CPP="cpp-${GCC_VER}"
is-mac && LD="gcc-${GCC_VER}"
unset GCC_VER
export CC CXX CPP LD

# MacOS Flags
is-mac && CFLAGS="-fbracket-depth=512 -fPIC"
is-mac && CXXFLAGS="-fbracket-depth=512 -fPIC"
export CFLAGS CXXFLAGS
