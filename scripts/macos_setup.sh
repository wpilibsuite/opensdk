#! /usr/bin/env bash

IS_MAC=false
[[ "$OSTYPE" == "darwin"* ]] && IS_MAC=true

$IS_MAC && PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
$IS_MAC && PATH="/usr/local/opt/gnu-tar/libexec/gnubin:$PATH"

# Clang appears to have issues
GCC_VER=10
$IS_MAC && CC="gcc-${GCC_VER}"
$IS_MAC && CXX="g++-${GCC_VER}"
$IS_MAC && CPP="cpp-${GCC_VER}"
$IS_MAC && LD="gcc-${GCC_VER}"
unset GCC_VER 

# MacOS Flags
$IS_MAC && CFLAGS="-fbracket-depth=512 -fPIC"
$IS_MAC && CXXFLAGS="-fbracket-depth=512 -fPIC"

unset IS_MAC
$IS_MAC && export PATH CC CXX CFLAGS CXXFLAGS
