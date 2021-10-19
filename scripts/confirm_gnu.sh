#! /usr/bin/env bash

function cmd-check {
    $1 --version | grep -q "GNU $1\|GNU coreutils" || return
}

TO_TEST=( tar cp readlink )

IS_GNU=true

for cmd in "${TO_TEST[@]}"
do
    printf "Testing %s... " "$cmd"
    if cmd-check "$cmd"; then
        echo "Passed"
    else
        echo "Failed"
        IS_GNU=false
        break
    fi
done

if "$IS_GNU"; then
    echo "All tools are part of GNU coreutils"
    exit 0
else
    echo "Some tools cannot be confirmed to be part of GNU coreutils"
    exit 1
fi
