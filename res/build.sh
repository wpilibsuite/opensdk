#! /usr/bin/env bash

TAGS=( "alpine" "14.04" "20.04" )
BIN_PWD="$(dirname "$0")"

if ! [[ " ${TAGS[@]} " =~ " $TAG " ]]; then
    echo "Tag not found. Try one of these..."
    echo "${TAGS[@]}"
    exit 1
fi

DOCKERFILE=Dockerfile
[[ "$TAG" =~ *"alpine" ]] && DOCKERFILE=Dockerfile.alpine

pushd "$BIN_PWD"
docker build \
    --build-arg BASE="$TAG" \
    -t "wpilib/toolchain-builder:$TAG" \
    -f "$DOCKERFILE" \
    . || exit
popd
