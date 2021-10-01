#! /bin/sh

set -e

DOCKER_ARG=""
if [ "$CI" != true ]; then
    DOCKER_ARG="-it"
fi

docker run \
    --rm $DOCKER_ARG -v "${PWD}:/work" \
    -e CI="$CI" \
    "ghcr.io/ryanhir/toolchain-builder:latest" \
    bash -c "cd /work; ./build.sh '$1' '$2' '$3'"

