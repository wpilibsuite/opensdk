#! /usr/bin/env bash

cd "$(dirname "$0")" || exit

echo "Simple C compiler test begin"
"$CC" ./main.c -o a.out || exit $?
file a.out
rm a.out || exit $?
echo "Simple C compiler test passed"
