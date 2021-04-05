#! /usr/bin/env bash

TAG="$1" bash res/build.sh

if [ "$CI" != true ]; then
    DOCKER_ARG="-it"
fi

docker run \
    --rm $DOCKER_ARG -v "${PWD}:/work" \
    -e CI="$CI" \
    "wpilib/toolchain-builder:$1" \
    bash -c "cd /work; ./test.sh '$2' '$3' '$4'"
