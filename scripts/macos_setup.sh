#! /usr/bin/env bash

IS_MAC=false
[[ "$OSTYPE" == "darwin"* ]] && IS_MAC=true

$IS_MAC && PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
$IS_MAC && PATH="/usr/local/opt/gnu-tar/libexec/gnubin:$PATH"

export PATH
