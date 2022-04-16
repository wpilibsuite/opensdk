#! /usr/bin/env bash

CONTAINER_IMAGE="ghcr.io/ryanhir/toolchain-builder"
CONTAINER_VERSION="bionic"

DOCKER_ARGS=(
    --rm
    -v "${PWD}:/work"
    -v "/etc/group:/etc/group:ro"
    -v "/etc/passwd:/etc/passwd:ro"
    -w "/work"
    -e CI="$CI"
    --platform "linux/amd64"
    --user "$(id -u):$(id -g)"
)

die() {
    echo "ERROR:" "$@" >&2
    exit 1
}

if [ "$CI" != "true" ]; then
    DOCKER_ARGS+=("-it")
fi

# Check if system is Linux
if [ "$(uname)" != "Linux" ]; then
    die "This script is only for Linux runners"
fi

# Check if docker is installed
if ! command -v docker >/dev/null 2>&1; then
    die "Docker is not installed"
fi

# Check if the user is in the docker group
if ! groups | grep -q docker; then
    die "You must be in the docker group"
fi

# Check if docker daemon is running
if ! docker info >/dev/null 2>&1; then
    die "Docker daemon is not running"
fi

# Check if working directory exists
if [ ! -d "${PWD}" ]; then
    # This should never happen
    die "Working directory does not exist"
fi

docker run \
    "${DOCKER_ARGS[@]}" \
    "${CONTAINER_IMAGE}:${CONTAINER_VERSION}" \
    bash -c "$*"
