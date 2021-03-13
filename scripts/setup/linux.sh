#! /usr/bin/env bash

is-linux && CC="${WPIHOSTTARGET}-gcc"
is-linux && CXX="${WPIHOSTTARGET}-g++"
is-linux && CPP="${WPIHOSTTARGET}-cpp"
is-linux && LD="${WPIHOSTTARGET}-ld"
export CC CXX CPP LD

is-linux && CFLAGS=""
is-linux && CXXFLAGS=""
export CFLAGS CXXFLAGS
