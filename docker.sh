#! /usr/bin/env bash
# Copyright 2021-2023 Ryan Hirasaki
#
# This file is part of OpenSDK
#
# OpenSDK is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# OpenSDK is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with OpenSDK; see the file COPYING. If not see
# <http://www.gnu.org/licenses/>.

CONTAINER_IMAGE="docker.io/wpilib/opensdk-ubuntu"
CONTAINER_VERSION="22.04"

DOCKER_ARGS=(
    --rm
    -v "${PWD}:/work"
    -v "/etc/group:/etc/group:ro"
    -v "/etc/passwd:/etc/passwd:ro"
    -w "/work"
    --tmpfs "${HOME}/.cache"
    --tmpfs "${HOME}/.local"
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
