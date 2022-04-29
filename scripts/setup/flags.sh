#! /usr/bin/env bash
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

if [ "$WPI_HOST_NAME" = "Windows" ]; then
    CFLAGS="$CFLAGS -static-libgcc -static-libstdc++"
    CXXFLAGS="$CXXFLAGS -static-libgcc -static-libstdc++"
    LDFLAGS="$LDFLAGS -static-libgcc -static-libstdc++"
fi
export CFLAGS CXXFLAGS LDFLAGS

# Make-server processes
if [ "$WPI_USE_THREADS" ]; then
    JOBS="$WPI_USE_THREADS"
else
    if [ "$WPI_HOST_NAME" = "Mac" ]; then
        JOBS="$(sysctl -n hw.ncpu)"
    else
        JOBS="$(nproc)"
    fi
    # Allow one empty thread so you can still
    # use the machine as you are compiling.
    JOBS="$(( "$JOBS" - 1 ))"
fi
export JOBS
