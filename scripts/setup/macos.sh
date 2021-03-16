#! /usr/bin/env bash

is-mac && PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
is-mac && PATH="/usr/local/opt/gnu-tar/libexec/gnubin:$PATH"
export PATH

# Clang appears to have issues
GCC_VER=10
is-mac && CC="clang" # XCode
is-mac && CXX="clang++" # XCode
# is-mac && CPP="cpp-$GCC_VER"
is-mac && LD="ld" # Apple linker
unset GCC_VER
export CC CXX CPP LD

# MacOS Flags
is-mac && CFLAGS="-fcommon"
is-mac && CXXFLAGS="-fcommon"
export CFLAGS CXXFLAGS
