#! /usr/bin/env bash

is-mac && PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
is-mac && PATH="/usr/local/opt/binutils/libexec/gnubin:$PATH"
is-mac && PATH="/usr/local/opt/gnu-tar/libexec/gnubin:$PATH"
export PATH