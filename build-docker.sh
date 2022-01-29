#! /bin/bash

set -e

DOCKER_ARG=""
if [ "$CI" != true ]; then
    DOCKER_ARG="-it"
fi

PLATFORM="linux/amd64"
VERSION="bionic"

docker run \
    --rm $DOCKER_ARG -v "${PWD}:/work" \
    --platform "${PLATFORM}" \
    -e CI="$CI" \
    "ghcr.io/ryanhir/toolchain-builder:${VERSION}" \
    bash -c "cd /work; ./build.sh '$1' '$2' '$3'"

