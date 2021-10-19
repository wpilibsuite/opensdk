#! /usr/bin/env bash

if is-mac; then
    BREW_PREFIX="$(brew --prefix)"
    GNU_PROJECTS=(coreutils binutils gnu-tar make)
    for project in "${GNU_PROJECTS[@]}"; do
        PATH="${BREW_PREFIX}/opt/${project}/bin:$PATH"
        PATH="${BREW_PREFIX}/opt/${project}/libexec/gnubin:$PATH"
    done
    unset BREW_PREFIX
    unset GNU_PROJECTS
    export PATH
fi
