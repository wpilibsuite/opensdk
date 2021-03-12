#! /usr/bin/env bash

is-mac && PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
is-mac && PATH="/usr/local/opt/gnu-tar/libexec/gnubin:$PATH"
export PATH

# Clang appears to have issues
GCC_VER=10
is-mac && CC="gcc-$GCC_VER"
is-mac && CXX="g++-$GCC_VER"
is-mac && CPP="cpp-$GCC_VER"
is-mac && LD="ld"
unset GCC_VER
export CC CXX CPP LD

# MacOS Flags
is-mac && CFLAGS="-fPIC -fcommon -std=gnu11"
is-mac && CXXFLAGS="-fPIC -fcommon -std=gnu++11"
export CFLAGS CXXFLAGS
