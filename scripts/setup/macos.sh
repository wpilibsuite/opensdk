#! /usr/bin/env bash

is-mac || return 0

PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
PATH="/usr/local/opt/gnu-tar/libexec/gnubin:$PATH"
export PATH

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
CPPFLAGS="-isysroot $SDK_PATH/MacOSX${WPI_HOST_SDK_CUR}.sdk
    -I$SDK_PATH/MacOSX${WPI_HOST_SDK_CUR}.sdk/usr/include/
    -mmacosx-version-min=${WPI_HOST_SDK_MIN}"
CFLAGS="${CPPFLAGS} -fcommon $WPI_HOST_CPP_FLAGS_APPEND"
CXXFLAGS="${CPPFLAGS} -fcommon $WPI_HOST_CPP_FLAGS_APPEND"

export CPPFLAGS CFLAGS CXXFLAGS
unset SDK_PATH

