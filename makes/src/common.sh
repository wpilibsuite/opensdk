#! /usr/bin/env bash
# shellcheck disable=SC2155

export CFLAGS="$CFLAGS -g -O2"
export CXXFLAGS="$CXXFLAGS -g -O2"

export FFLAGS_FOR_TARGET="-g -O2"
export CFLAGS_FOR_TARGET="-g -O2"
export CXXFLAGS_FOR_TARGET="-g -O2"

source "$(dirname "$0")/utils/funcs.sh"

if [ "${FUNC_ONLY}" = "true" ]; then
    return 0
fi

# If these fail, then others are bad aswell
env_exists V_BIN
env_exists V_GDB
env_exists V_GCC
env_exists WPI_HOST_PREFIX
env_exists DOWNLOAD_DIR


BUILD_TUPLE="${WPI_BUILD_TUPLE}"
HOST_TUPLE="${WPI_HOST_TUPLE}"
SYSROOT_PATH="${WPI_HOST_PREFIX}/${TARGET_TUPLE}/sysroot"
SYSROOT_BUILD_PATH="$BUILD_DIR/sysroot-install/${TARGET_TUPLE}/sysroot"

CONFIGURE_COMMON_LITE=(
    "--build=${BUILD_TUPLE}"
    "--host=${HOST_TUPLE}"
    "--prefix=${WPI_HOST_PREFIX}"
    "--program-prefix=${TARGET_PREFIX}"
    "--disable-lto"
    "--disable-nls"
    "--disable-plugin"
    "--disable-werror"
    "--disable-dependency-tracking"
)

CONFIGURE_COMMON=(
    "${CONFIGURE_COMMON_LITE[@]}"
    "--target=${TARGET_TUPLE}"
    "--libexecdir=${WPI_HOST_PREFIX}/${TARGET_TUPLE}/libexec"
    "--with-sysroot=${SYSROOT_PATH}"
    "--libdir=${SYSROOT_PATH}/usr/lib"
    "--with-toolexeclibdir=${SYSROOT_PATH}/usr/lib"
    "--with-build-sysroot=${SYSROOT_BUILD_PATH}"
)

export PATH="/tmp/frc/bin:${PATH}"
export CONFIGURE_COMMON_LITE CONFIGURE_COMMON
if [ "${BUILD_TUPLE}" != "${HOST_TUPLE}" ]; then
    # Manually tell autoconf what tools to use as the build, host, and target
    # compilers may be intended for different systems even though they have
    # the same prefix due to the tuple matching.
    configure_host_vars
    configure_target_vars
fi
