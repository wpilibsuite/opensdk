#! /usr/bin/env bash

is-mac || return 0

PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
PATH="/usr/local/opt/gnu-tar/libexec/gnubin:$PATH"
export PATH

SDK_BINS="/Library/Developer/CommandLineTools/usr/bin"
SDK_PATH="/Library/Developer/CommandLineTools/SDKs"

# override autotools program prefix as this is LLVM
CC="$SDK_BINS/cc"
CXX="$SDK_BINS/c++"
AR="$SDK_BINS/ar"
LD="$SDK_BINS/ld"
NM="$SDK_BINS/nm"
RANLIB="$SDK_BINS/ranlib"
LIPO="$SDK_BINS/lipo"
OBJDUMP="$SDK_BINS/objdump"
export CC CXX AR LD NM RANLIB LIPO OBJDUMP

ls -l "$SDK_PATH"
[ -d "$SDK_PATH/MacOSX${WPI_HOST_SDK_CUR}.sdk" ] || exit

# MacOS Flags
CPPFLAGS="-isysroot $SDK_PATH/MacOSX${WPI_HOST_SDK_CUR}.sdk -mmacosx-version-min=${WPI_HOST_SDK_MIN}"
CFLAGS="$CPPFLAGS -fcommon $WPI_HOST_CPP_FLAGS_APPEND"
CXXFLAGS="$CPPFLAGS -fcommon $WPI_HOST_CPP_FLAGS_APPEND"
unset SDK_BINS
unset SDK_PATH

export CPPFLAGS CFLAGS CXXFLAGS
