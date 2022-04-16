#! /usr/bin/env bash
# shellcheck disable=SC2155

function die() {
    echo "[FATAL]: $1" >&2
    exit 1
}

function warn() {
    echo "[WARN]: $1" >&2
}

function xpushd() {
    pushd "$1" >/dev/null || die "pushd failed: $1"
}

function xpopd() {
    popd >/dev/null || die "popd failed"
}

function xcd() {
    cd "$1" >/dev/null || die "cd failed"
}

function process_background() {
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

configure_host_vars() {
    local xcode_arch_flag
    local xcode_sdk_flag
    local xcrun_find
    # xcode_sdk_flag="-isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk"
    xcrun_find="xcrun --sdk macosx -f"

    env_exists WPI_HOST_NAME
    env_exists WPI_HOST_TUPLE
    env_exists HOST_TUPLE

    if [ "$WPI_HOST_NAME" = "Mac" ]; then
        case "${WPI_HOST_TUPLE}" in
        arm64* | aarch64*) xcode_arch_flag="-arch arm64" ;;
        x86_64*) xcode_arch_flag="-arch x86_64" ;;
        *) die "Unsupported Canadian config" ;;
        esac

        export AR="$($xcrun_find ar)"
        export AS="$($xcrun_find as) $xcode_arch_flag"
        export LD="$($xcrun_find ld) $xcode_arch_flag $xcode_sdk_flag"
        export NM="$($xcrun_find nm) $xcode_arch_flag"
        export STRIP="$($xcrun_find strip) $xcode_arch_flag"
        export RANLIB="$($xcrun_find ranlib)"
        export OBJDUMP="$($xcrun_find objdump)"
        export CC="$($xcrun_find gcc) $xcode_arch_flag $xcode_sdk_flag"
        export CXX="$($xcrun_find g++) $xcode_arch_flag $xcode_sdk_flag"
    else
        export AR="/usr/bin/${HOST_TUPLE}-ar"
        export AS="/usr/bin/${HOST_TUPLE}-as"
        export LD="/usr/bin/${HOST_TUPLE}-ld"
        export NM="/usr/bin/${HOST_TUPLE}-nm"
        export RANLIB="/usr/bin/${HOST_TUPLE}-ranlib"
        export STRIP="/usr/bin/${HOST_TUPLE}-strip"
        export OBJCOPY="/usr/bin/${HOST_TUPLE}-objcopy"
        export OBJDUMP="/usr/bin/${HOST_TUPLE}-objdump"
        export READELF="/usr/bin/${HOST_TUPLE}-readelf"
        export CC="/usr/bin/${HOST_TUPLE}-gcc"
        export CXX="/usr/bin/${HOST_TUPLE}-g++"
    fi
}

configure_target_vars() {
    env_exists TARGET_TUPLE

    define_target_export() {
        local var="${1}_FOR_TARGET"
        local tool="${TARGET_TUPLE}-$2"
        if [ "${!var}" ]; then
            die "$var is already set with '${!var}'"
        else
            export "${var}"="/opt/frc/bin/${tool}"
        fi
    }

    define_target_export AR ar
    define_target_export AS as
    define_target_export LD ld
    define_target_export NM nm
    define_target_export RANLIB ranlib
    define_target_export STRIP strip
    define_target_export OBJCOPY objcopy
    define_target_export OBJDUMP objdump
    define_target_export READELF readelf
    define_target_export CC gcc
    define_target_export CXX g++
    define_target_export GCC gcc
    define_target_export GFORTRAN gfortran
}

check_if_canandian_stage_one_succeded() {
    env_exists TARGET_TUPLE
    if ! [[ -x "/opt/frc/bin/${TARGET_TUPLE}-gcc" ]]; then
        echo "[DEBUG]: Cannot find ${TARGET_TUPLE}-gcc in /opt/frc/bin"
        die "Stage 1 Canadian toolchain not found in expected location"
    fi
}

gcc_update_target_list() {
    gcc_need_lib_build() {
        local lib="${SYSROOT_BUILD_PATH}/usr/lib/$1"
        if [ "$TARGET_LIB_REBUILD" = "true" ]; then
            return 0
        fi
        if compgen -G "${lib}.*" >/dev/null; then
            return 1
        fi
        return 0
    }
    if gcc_need_lib_build libgcc; then
        GCC_TASKS+=(
            target-libgcc
        )
    fi
    if gcc_need_lib_build libatomic; then
        GCC_TASKS+=(
            target-libatomic
        )
    fi
    if gcc_need_lib_build asan || gcc_need_lib_build ubsan; then
        GCC_TASKS+=(
            target-libsanitizer
        )
    fi
    if gcc_need_lib_build libstdc++ && [ "${TARGET_ENABLE_CXX}" = true ]; then
        GCC_TASKS+=(
            target-libstdc++-v3
        )
    fi
    if gcc_need_lib_build libgfortran && [ "${TARGET_ENABLE_FORTRAN}" = true ]; then
        GCC_TASKS+=(
            target-libgfortran
        )
    fi
}

is_lib_rebuild_required() {
    local -a GCC_TASKS
    gcc_update_target_list
    if [ "${#GCC_TASKS[@]}" -gt 0 ]; then
        return 0
    fi
    return 1
}

is_simple_cross() {
    if [ "${WPI_HOST_CANADIAN}x" != "x" ]; then
        return 1
    else
        return 0
    fi
}

is_step_backend() {
    [ "$BUILD_BACKEND" = true ]
}

is_step_frontend() {
    [ "$BUILD_BACKEND" != true ]
}

is_internal_toolchain() {
    [ "$BUILD_BACKEND" = true ] || [ "$CANADIAN_STAGE_ONE" = true ]
}