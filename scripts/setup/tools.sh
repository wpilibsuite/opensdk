#! /usr/bin/env bash

function is-mac() {
    [[ "$OSTYPE" == "darwin"* ]] || return
}

function is-linux() {
    [[ "$OSTYPE" == "linux"* ]] || return
}

function is-actions() {
    [ "$CI" = "true" ] || return
}

function is-mac-codesign() {
    is-mac && is-actions &&
        [ -n "${APPLE_DEVELOPER_ID}" ] || return
}
