#! /usr/bin/env bash

is-mac || return 0

SDK_PATH="/Library/Developer/CommandLineTools/SDKs"

ls -l "$SDK_PATH"
[ -d "$SDK_PATH/MacOSX.sdk" ] || exit

MacOS Flags
CPPFLAGS="-isysroot $SDK_PATH/MacOSX.sdk"
CPPFLAGS+=" -I$SDK_PATH/MacOSX.sdk/usr/include/"
CPPFLAGS+=" -mmacosx-version-min=${WPI_HOST_SDK_MIN}"
CFLAGS="${CPPFLAGS} -fcommon $WPI_HOST_CPP_FLAGS_APPEND"
CXXFLAGS="${CPPFLAGS} -fcommon $WPI_HOST_CPP_FLAGS_APPEND"

export CPPFLAGS CFLAGS CXXFLAGS
unset SDK_PATH

