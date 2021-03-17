#! /usr/bin/env bash

is-mac || return 0

PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
PATH="/usr/local/opt/gnu-tar/libexec/gnubin:$PATH"
export PATH

CC="cc" # XCode
CXX="c++" # XCode
AR="ar" # Xcode
LD="ld" # Xcode
export CC CXX AR LD

SDK_PATH="/Library/Developer/CommandLineTools/SDKs"
ls -l "$SDK_PATH"

# MacOS Flags
CPPFLAGS="-isysroot $SDK_PATH/MacOSX${WPI_HOST_SDK_CUR}.sdk -mmacosx-version-min=${WPI_HOST_SDK_MIN}"
CFLAGS="$CPPFLAGS -fcommon $WPI_HOST_CPP_FLAGS_APPEND"
CXXFLAGS="$CPPFLAGS -fcommon $WPI_HOST_CPP_FLAGS_APPEND"

# The following was a test for universal binary
# CFLAGS="$CPPFLAGS -fcommon -arch arm64 -arch x86_64"
# CXXFLAGS="$CPPFLAGS -fcommon -arch arm64 -arch x86_64"
unset SDK_PATH

export CPPFLAGS CFLAGS CXXFLAGS
