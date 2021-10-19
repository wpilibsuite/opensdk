#! /usr/bin/env bash

set -e

DOCKER_ARG=""
if [ "$CI" != true ]; then
    DOCKER_ARG="-it"
fi

PLATFORM="linux/amd64"
if [[ "$1" =~ "linux_i686" ]]; then
    PLATFORM="linux/386"
fi

docker run \
    --rm $DOCKER_ARG -v "${PWD}:/work" \
    --platform "${PLATFORM}" \
    -e CI="$CI" \
    "ghcr.io/ryanhir/toolchain-builder:latest" \
    bash -c "cd /work; ./test.sh '$1' '$2' '$3'"
