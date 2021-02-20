#! /usr/bin/env bash

function find_in_path() {
    if ! command -v "$1" > /dev/null; then
        echo "Cannot find compiler $1"
        exit 1 # err
    fi
}

CC_COMMAND="${WPIHOSTTARGET}-gcc"
CXX_COMMAND="${WPIHOSTTARGET}-g++"
[ "${WPITARGET}" = "Mac" ] && CC_COMMAND="clang"
[ "${WPITARGET}" = "Mac" ] && CXX_COMMAND="clang++"

find_in_path "${CC_COMMAND}"
find_in_path "${CXX_COMMAND}"

exit 0 # pass
