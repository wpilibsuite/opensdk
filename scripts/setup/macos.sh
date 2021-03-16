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
SDK_PATH="/Library/Developer/CommandLineTools/SDKs/"
CPPFLAGS="-isysroot $SDK_PATH/MacOSX11.0.sdk  -mmacosx-version-min=10.14"
CFLAGS="$CPPFLAGS -fcommon -arch arm64 -arch x86_64"
CXXFLAGS="$CPPFLAGS-fcommon -arch arm64 -arch x86_64"
unset SDK_PATH

export CPPFLAGS CFLAGS CXXFLAGS
