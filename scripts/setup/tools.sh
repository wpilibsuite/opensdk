#! /usr/bin/env bash

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
