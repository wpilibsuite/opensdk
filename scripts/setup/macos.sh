#! /usr/bin/env bash

# This will tell the compiler and linker what version
# of macOS to target. For M1, Xcode will default to
# version 11.0
export MACOSX_DEPLOYMENT_TARGET=10.14

if [[ "$(cc -dumpmachine)" =~ $WPI_HOST_TUPLE ]]; then
    # Native build
    export WPI_HOST_TUPLE="$(cc -dumpmachine)"
fi
