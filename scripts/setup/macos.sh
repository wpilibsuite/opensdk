#! /usr/bin/env bash

is-mac || return 0

PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
PATH="/usr/local/opt/gnu-tar/libexec/gnubin:$PATH"
export PATH

SDK_BINS="/Library/Developer/CommandLineTools/usr/bin"
SDK_PATH="/Library/Developer/CommandLineTools/SDKs"

CC="cc"
CXX="c++"
AR="ar"
LD="ld"
NM="nm"
RANLIB="ranlib"
LIPO="lipo"
OBJDUMP="objdump"
export CC CXX AR LD NM RANLIB LIPO OBJDUMP

ls -l "$SDK_PATH"
[ -d "$SDK_PATH/MacOSX${WPI_HOST_SDK_CUR}.sdk" ] || exit

# MacOS Flags
CPPFLAGS=( # do this so we can maintain with arrays
    "-isysroot $SDK_PATH/MacOSX${WPI_HOST_SDK_CUR}.sdk"
    "-I$SDK_PATH/MacOSX${WPI_HOST_SDK_CUR}.sdk/usr/include/"
    "-mmacosx-version-min=${WPI_HOST_SDK_MIN}"
)
CFLAGS=(
    "${CPPFLAGS[@]}"
    "-fcommon"
    "$WPI_HOST_CPP_FLAGS_APPEND"
)
CXXFLAGS=(
    "${CPPFLAGS[@]}"
    "-fcommon"
    "$WPI_HOST_CPP_FLAGS_APPEND"
)
unset SDK_BINS
unset SDK_PATH

CFLAGS="$(echo "${CFLAGS[@]}")"
CXXFLAGS="$(echo "${CXXFLAGS[@]}")"
CPPFLAGS="$(echo "${CPPFLAGS[@]}")"
export CPPFLAGS CFLAGS CXXFLAGS
