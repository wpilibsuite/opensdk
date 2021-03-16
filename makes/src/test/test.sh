#! /usr/bin/env bash

cd "$(dirname "$0")"

[ -z "$CC" ] && CC=gcc

FAIL=true

"$CC" $CFLAGS ./main.c -o a.out && {
    file a.out
    rm a.out
    FAIL=false
} > /dev/null

if $FAIL; then
    "$CC Failed to build"
    exit 1
fi
