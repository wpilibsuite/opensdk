#! /usr/bin/env bash

IS_MAC=false
[[ "$OSTYPE" == "darwin"* ]] && IS_MAC=true

$IS_MAC && PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
$IS_MAC && PATH="/usr/local/opt/gnu-tar/libexec/gnubin:$PATH"

# Clang Specific
$IS_MAC && CFLAGS="-fbracket-depth=512"
$IS_MAC && CXXFLAGS="-fbracket-depth=512"

unset IS_MAC
export PATH CFLAGS CXXFLAGS
