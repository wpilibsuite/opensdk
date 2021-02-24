#! /usr/bin/env bash

# Do not continue if MacOS
is-mac && return 0

CC="${WPIHOSTTARGET}-gcc"
CXX="${WPIHOSTTARGET}-g++"
CPP="${WPIHOSTTARGET}-cpp"
LD="${WPIHOSTTARGET}-ld"
export CC CXX CPP LD

CFLAGS=""
CXXFLAGS=""
export CFLAGS CXXFLAGS
