#! /bin/sh

no() {
    echo "false"
    exit
}

_MACHINE="$(uname)"

if [ "$_MACHINE" != "Linux" ]; then
    no
elif ! command -v docker >/dev/null 2>&1; then
    # Check if docker is installed
    no    
elif ! groups | grep -q docker; then
    # Check if the user is in the docker group
    no    
elif ! docker info >/dev/null 2>&1; then
    # Check if docker daemon is running
    no
fi

echo "true"
