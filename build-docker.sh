#! /usr/bin/env bash

TAGS=( "14.04" "18.04" )

if ! SKIP_IMG_BUILD; then
    for tag in "${TAGS[@]}"; do
        docker build \
            -t "wpilib/toolchain-builder:$tag" \
            --build-arg BASE="$tag" .
    done
fi

if ! [[ " ${TAGS[@]} " =~ " $1 " ]]; then
    echo "Tag not found. Try one of these..."
    echo "${TAGS[@]}"
    exit 1
fi

[ "$CI" != true ] && DOCKER_ARG="-it"

docker run \
    --rm $DOCKER_ARG -v "${PWD}:/work" \
    "wpilib/toolchain-builder:$1" \
    bash -c "cd /work; ./build.sh '$2' '$3'"