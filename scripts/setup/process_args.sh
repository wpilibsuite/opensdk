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

if [ "$#" != "3" ]; then
    exit 1
fi

HOST_CFG="$1"
TARGET_CFG="$2"
TARGET_PORT="$3"
TOOLCHAIN_NAME="$(basename "$TARGET_CFG")"
export HOST_CFG TARGET_CFG TARGET_PORT TOOLCHAIN_NAME

if ! [ -f "$HOST_CFG" ]; then
    echo "Cannot find selected host at $HOST_CFG"
    exit 1
fi

if ! [ -f "$TARGET_CFG/version.env" ]; then
    echo "$TARGET_CFG is not a supported toolchain"
    exit 1
fi

if ! grep -q "$TARGET_PORT" "$TARGET_CFG/ports.txt"; then
    echo "[ERR] $TARGET_PORT is not supported in $TOOLCHAIN_NAME"
    exit 1
fi
