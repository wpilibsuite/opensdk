#! /bin/sh

set -e
sh res/build.sh

DOCKER_ARG=""
if [ "$CI" != true ]; then
    DOCKER_ARG="-it"
fi

docker run \
    --rm $DOCKER_ARG -v "${PWD}:/work" \
    -e CI="$CI" \
    "wpilib/toolchain-builder:latest" \
    bash -c "cd /work; ./build.sh '$1' '$2' '$3'"

