#! /bin/sh

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

_MACHINE_NAME="$(uname)"
_MACHINE_ARCH="$(uname -m)"

if [ "$_MACHINE_NAME" = "Darwin" ]; then
    echo "macos_${_MACHINE_ARCH}"
elif [ "$_MACHINE_NAME" = "Linux" ]; then
    echo "linux_${_MACHINE_ARCH}"
else
    echo "Unknown host: $_MACHINE_NAME" >&2
    exit 1
fi
