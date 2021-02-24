#! /usr/bin/env bash

set -e -x

cd "$(dirname "$0")"

"$CC" ./main.c -o a.out
file a.out
rm a.out
