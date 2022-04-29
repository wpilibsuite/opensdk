#! /bin/sh

# Copyright 2021-2022 Ryan Hirasaki
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
