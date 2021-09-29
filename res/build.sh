#! /bin/sh

BIN_PWD="$(dirname "$0")"
DOCKERFILE=Dockerfile

cd "$BIN_PWD" || exit
docker build \
    -t "wpilib/toolchain-builder:latest" \
    -f "$DOCKERFILE" \
    . || exit

