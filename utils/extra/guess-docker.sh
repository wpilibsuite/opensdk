#! /bin/sh

_MACHINE="$(uname)"

if [ "$_MACHINE" != "Linux" ]; then
    echo "false"
elif [ "$CI" = "true" ]; then
    # Github Actions already runs in a Docker container
    echo "false"
elif ! command -v docker >/dev/null 2>&1; then
    # Check if docker is installed
    echo "false"
elif ! groups | grep -q docker; then
    # Check if the user is in the docker group
    echo "false"
elif ! docker info >/dev/null 2>&1; then
    # Check if docker daemon is running
    echo "false"
else
    echo "true"
fi
