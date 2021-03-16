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

ls -l "/Library/Developer/CommandLineTools/SDKs/"

# MacOS Flags
SDK_NAME="MacOSX${WPI_HOST_SDK_CUR}.sdk"
SDK_PATH="/Applications/Xcode_12.4.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/$SDK_NAME"
CPPFLAGS="-isysroot $SDK_PATH -mmacosx-version-min=${WPI_HOST_SDK_MIN}"
CFLAGS="$CPPFLAGS -fcommon -arch arm64 -arch x86_64"
CXXFLAGS="$CPPFLAGS -fcommon -arch arm64 -arch x86_64"
unset SDK_NAME SDK_PATH

export CPPFLAGS CFLAGS CXXFLAGS
