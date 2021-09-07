#! /usr/bin/env bash

if is-mac; then
    case "$(uname -m)" in
    x86_64)
        PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
        PATH="/usr/local/opt/binutils/libexec/gnubin:$PATH"
        PATH="/usr/local/opt/gnu-tar/libexec/gnubin:$PATH"
        ;;
    arm64)
        PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
        PATH="/opt/homebrew/opt/binutils/libexec/gnubin:$PATH"
        PATH="/opt/homebrew/opt/gnu-tar/libexec/gnubin:$PATH"
        ;;
    *)
        echo "[FATAL] Unsupported macOS build system."
        exit 1
        ;;
    esac
    export PATH
fi
