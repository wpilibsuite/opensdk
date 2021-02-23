#! /usr/bin/env bash

IS_MAC=false
[[ "$OSTYPE" == "darwin"* ]] && IS_MAC=true

$IS_MAC && PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
$IS_MAC && PATH="/usr/local/opt/gnu-tar/libexec/gnubin:$PATH"

# Clang appears to have issues
$IS_MAC && CC="gcc-10"
$IS_MAC && CC="g++-10"

# MacOS Flags
$IS_MAC && CFLAGS="-fbracket-depth=512 -fPIC"
$IS_MAC && CXXFLAGS="-fbracket-depth=512 -fPIC"

unset IS_MAC
$IS_MAC && export PATH CC CXX CFLAGS CXXFLAGS
