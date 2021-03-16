#! /usr/bin/env bash

is-mac && PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
is-mac && PATH="/usr/local/opt/gnu-tar/libexec/gnubin:$PATH"
# is-mac && PATH="/Applications/Xcode_12.4.app/Contents/Developer/usr/bin:$PATH"
export PATH

is-mac && CC="clang" # XCode
is-mac && CXX="clang++" # XCode
# is-mac && CPP="cpp-$GCC_VER"
is-mac && LD="ld" # Apple linker
export CC CXX LD


# MacOS Flags
is-mac && CFLAGS="-fcommon -arch arm64 -arch x86_64"
is-mac && CXXFLAGS="-fcommon -arch arm64 -arch x86_64"
is-mac && LDFLAGS="-target -arch arm64 -arch x86_64"

export CFLAGS CXXFLAGS
