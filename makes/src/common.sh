#! /usr/bin/env bash
# shellcheck disable=SC2155

function die() {
    echo "[FATAL]: $1" >&2
    exit 1
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
    local rand="$(tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 10 | head -n 1)"
    mkdir -p "/tmp/toolchain_builder/"
    local prefix
    if [ "$msg" ]; then
        prefix="[RUNNING]: $msg"
    else
        prefix="[RUNNING]: Background task '${*}'"
    fi
    ("${@}") >"/tmp/toolchain_builder/${rand}.log" 2>&1 &
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
        cat "/tmp/toolchain_builder/${rand}.log"
    fi
    rm "/tmp/toolchain_builder/${rand}.log"
    return "$retval"
}

# If these fail, then others are bad aswell
[ "${V_BIN:-fail}" != fail ] || die "V_BIN"
[ "${V_GDB:-fail}" != fail ] || die "V_GDB"
[ "${V_GCC:-fail}" != fail ] || die "V_GCC"
[ "${WPI_HOST_PREFIX:-fail}" != fail ] || die "prefix dir"
[ "${DOWNLOAD_DIR:-fail}" != fail ] || die "Download Dir"

if [ "${FUNC_ONLY}" = "true" ]; then
    return 0
fi

if [ "$WPI_BUILD_TUPLE" ]; then
    BUILD_TUPLE="$WPI_BUILD_TUPLE"
else
    BUILD_TUPLE="$(gcc -dumpmachine)"
fi
HOST_TUPLE="${WPI_HOST_TUPLE}"
SYSROOT_PATH="${WPI_HOST_PREFIX}/${TARGET_TUPLE}/sysroot"
SYSROOT_BUILD_PATH="$BUILD_DIR/sysroot-install/${TARGET_TUPLE}/sysroot"

CONFIGURE_COMMON_LITE=(
    "--build=${BUILD_TUPLE}"
    "--host=${HOST_TUPLE}"
    "--prefix=${WPI_HOST_PREFIX}"
    "--program-prefix=${TARGET_PREFIX}"
    "--enable-lto"
    "--disable-nls"
    "--disable-werror"
    "--disable-dependency-tracking"
)

CONFIGURE_COMMON=(
    "${CONFIGURE_COMMON_LITE[@]}"
    "--target=${TARGET_TUPLE}"
    "--libdir=${WPI_HOST_PREFIX}/${TARGET_TUPLE}/lib"
    "--libexecdir=${WPI_HOST_PREFIX}/${TARGET_TUPLE}/libexec"
    "--with-sysroot=${SYSROOT_PATH}"
)

if [ "${PREBUILD_CANADIAN}" != "true" ]; then
    # Normally use our in-tree sysroot unless we are on the second stage build
    CONFIGURE_COMMON+=("--with-build-sysroot=${SYSROOT_BUILD_PATH}")
else
    CONFIGURE_COMMON+=("--with-build-sysroot=/opt/frc/${TARGET_TUPLE}/sysroot")
fi

export PATH="/opt/frc/bin:${PATH}"
export CONFIGURE_COMMON_LITE CONFIGURE_COMMON
if [ "${PREBUILD_CANADIAN}" = "true" ]; then
    if ! [[ -x "/opt/frc/bin/${TARGET_TUPLE}-gcc" ]]; then
        echo "[DEBUG]: Cannot find ${TARGET_TUPLE}-gcc in /opt/frc/bin"
        die "Stage 1 Canadian toolchain not found in expected location"
    fi
    # Manually tell autoconf what tools to use as the build, host, and target
    # compilers may be intended for different systems even though they have
    # the same prefix due to the tuple matching.
    if [ "${WPI_HOST_NAME}" = "Mac" ]; then
        xcode_arch_flag=""
        xcode_sdk_flag=""
        # xcode_sdk_flag="-isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk"
        case "${WPI_HOST_TUPLE}" in
        arm64* | aarch64*) xcode_arch_flag="-arch arm64" ;;
        *) die "Unsupported Canadian config" ;;
        esac
        xcrun_find="xcrun --sdk macosx -f"

        AR="$($xcrun_find ar)"
        AS="$($xcrun_find as) $xcode_arch_flag"
        LD="$($xcrun_find ld) $xcode_arch_flag $xcode_sdk_flag"
        NM="$($xcrun_find nm) $xcode_arch_flag"
        STRIP="$($xcrun_find strip) $xcode_arch_flag"
        RANLIB="$($xcrun_find ranlib)"
        OBJDUMP="$($xcrun_find objdump)"
        CC="$($xcrun_find gcc) $xcode_arch_flag $xcode_sdk_flag"
        CXX="$($xcrun_find g++) $xcode_arch_flag $xcode_sdk_flag"
    else
        AR="/usr/bin/${HOST_TUPLE}-ar"
        AS="/usr/bin/${HOST_TUPLE}-as"
        LD="/usr/bin/${HOST_TUPLE}-ld"
        NM="/usr/bin/${HOST_TUPLE}-nm"
        RANLIB="/usr/bin/${HOST_TUPLE}-ranlib"
        STRIP="/usr/bin/${HOST_TUPLE}-strip"
        OBJCOPY="/usr/bin/${HOST_TUPLE}-objcopy"
        OBJDUMP="/usr/bin/${HOST_TUPLE}-objdump"
        READELF="/usr/bin/${HOST_TUPLE}-readelf"
        CC="/usr/bin/${HOST_TUPLE}-gcc"
        CXX="/usr/bin/${HOST_TUPLE}-g++"
    fi
    export AR
    export AS
    export LD
    export NM
    export RANLIB
    export STRIP
    export OBJCOPY
    export OBJDUMP
    export READELF
    export CC
    export CXX

    AR_FOR_TARGET="/opt/frc/bin/${TARGET_TUPLE}-ar"
    export AR_FOR_TARGET
    AS_FOR_TARGET="/opt/frc/bin/${TARGET_TUPLE}-as"
    export AS_FOR_TARGET
    LD_FOR_TARGET="/opt/frc/bin/${TARGET_TUPLE}-ld"
    export LD_FOR_TARGET
    NM_FOR_TARGET="/opt/frc/bin/${TARGET_TUPLE}-nm"
    export NM_FOR_TARGET
    RANLIB_FOR_TARGET="/opt/frc/bin/${TARGET_TUPLE}-ranlib"
    export RANLIB_FOR_TARGET
    STRIP_FOR_TARGET="/opt/frc/bin/${TARGET_TUPLE}-strip"
    export STRIP_FOR_TARGET
    OBJCOPY_FOR_TARGET="/opt/frc/bin/${TARGET_TUPLE}-objcopy"
    export OBJCOPY_FOR_TARGET
    OBJDUMP_FOR_TARGET="/opt/frc/bin/${TARGET_TUPLE}-objdump"
    export OBJDUMP_FOR_TARGET
    READELF_FOR_TARGET="/opt/frc/bin/${TARGET_TUPLE}-readelf"
    export READELF_FOR_TARGET
    CC_FOR_TARGET="/opt/frc/bin/${TARGET_TUPLE}-gcc"
    export CC_FOR_TARGET
    GCC_FOR_TARGET="${CC_FOR_TARGET}"
    export GCC_FOR_TARGET
    CXX_FOR_TARGET="/opt/frc/bin/${TARGET_TUPLE}-g++"
    export CXX_FOR_TARGET
    GFORTRAN_FOR_TARGET="/opt/frc/bin/${TARGET_TUPLE}-gfortran"
    export GFORTRAN_FOR_TARGET
fi
