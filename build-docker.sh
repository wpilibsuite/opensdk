#! /usr/bin/env bash

TAGS=( "alpine" "14.04" "18.04" )

if ! [[ " ${TAGS[@]} " =~ " $1 " ]]; then
    echo "Tag not found. Try one of these..."
    echo "${TAGS[@]}"
    exit 1
fi

FILE=ubuntu
[ "$1" = alpine ] && FILE=alpine

pushd "res"
docker build \
    --build-arg BASE="$1" \
    -t "wpilib/toolchain-builder:$1" \
    -f "Dockerfile.$FILE" \
    . || exit
popd

[ "$CI" != true ] && DOCKER_ARG="-it"

docker run \
   --rm $DOCKER_ARG -v "${PWD}:/work" \
   "wpilib/toolchain-builder:$1" \
   bash -c "cd /work; ./build.sh '$2' '$3' '$4'"
