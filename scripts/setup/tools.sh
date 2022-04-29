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

is_builder_mac() {
    [[ "$OSTYPE" == "darwin"* ]] || return
}

is_builder_linux() {
    [[ "$OSTYPE" == "linux"* ]] || return
}

die() {
    echo "[FATAL]: $1" >&2
    exit 1
}

warn() {
    echo "[WARN]: $1" >&2
}

xpushd() {
    pushd "$1" >/dev/null || die "pushd failed: $1"
}

xpopd() {
    popd >/dev/null || die "popd failed"
}

xcd() {
    cd "$1" >/dev/null || die "cd failed"
}

process_background() {
    local spin=("-" "\\" "|" "/")
    local msg="$1"
    shift
    local logfile="$(mktemp)"
    local prefix
    if [ "$msg" ]; then
        prefix="[RUNNING]: $msg"
    else
        prefix="[RUNNING]: Background task '${*}'"
    fi
    ("${@}") >"${logfile}" 2>&1 &
    local pid="$!"
    if [ "$CI" != "true" ]; then
        while (ps a | awk '{print $1}' | grep -q "$pid"); do
            for i in "${spin[@]}"; do
                echo -ne "\r$prefix $i"
                sleep 0.1
            done
        done
        echo -e "\r$prefix  "
    else
        echo "$prefix"
    fi
    wait "$pid"
    local retval="$?"
    if [ "$retval" -ne 0 ]; then
        cat "${logfile}"
    fi
    rm "${logfile}"
    return "$retval"
}

env_exists() {
    local env_var="$1"
    if [ -z "${!env_var}" ]; then
        die "$env_var is not set"
    else
        return 0
    fi
}

check_if_canandian_stage_one_succeded() {
    env_exists TARGET_TUPLE
    if ! [ -x "/tmp/frc/bin/${TARGET_TUPLE}-gcc" ]; then
        warn "Cannot find ${TARGET_TUPLE}-gcc in /tmp/frc/bin"
        die "Stage 1 Canadian toolchain not found in expected location"
    fi
}

is_canadian_stage_one() {
    [ "$CANADIAN_STAGE_ONE" = true ]
}

is_step_backend() {
    [ "$BUILD_BACKEND" = true ]
}

is_step_frontend() {
    ! is_step_backend
}

is_internal_toolchain() {
    is_step_backend || is_canadian_stage_one
}

is_final_toolchain() {
    ! is_internal_toolchain
}
