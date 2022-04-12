#! /usr/bin/bash

# This script is only to cleanup the sysroot and normalize
# and differences in the filesystem layout that exist between
# Debian and NI Linux. The goal is to have everyone follow a
# layout similar to NI Linux as it is easier to navigate.

# The Debian filesystem is better for multilib environments
# but this causes issues with a more vanilla version of
# binutils and GCC. So by using the NI Linux layout, we can
# avoid patching/hacking the build tools.

source "$(dirname "$0")/common.sh"

xcd "${BUILD_DIR}/sysroot-install/${TARGET_TUPLE}/sysroot"

if [ "${TARGET_DISTRO}" = "roborio" ]; then
    # Why is this here on the rio?
    rm -rf lib/cpp
else
    # lib
    rm -rf lib/ld-linux*.so*
    rsync -aEL lib/"${TARGET_TUPLE}"/ lib/
    rm -rf lib/"${TARGET_TUPLE}"

    # usr/include
    rsync -aEL usr/include/"${TARGET_TUPLE}"/ usr/include/
    rm -rf usr/include/"${TARGET_TUPLE}"

    # usr/lib
    rsync -aEL usr/lib/"${TARGET_TUPLE}"/ usr/lib/
    rm -rf usr/lib/"${TARGET_TUPLE}"

    rm -rf usr/lib/audit
    rm -rf usr/lib/bfd-plugins
    rm -rf usr/lib/compat-ld
    rm -rf usr/lib/gold-ld
    rm -rf usr/lib/ldscripts
    rm -rf usr/lib/mime

    # Point the libc linker script to correct location
    sed -i "s/\/lib\/${TARGET_TUPLE}/\/lib/g" usr/lib/libc.so
fi


if [ "${TARGET_LIB_REBUILD}" = "true" ]; then
    # Delete libstdc++ headers which will be replaced
    rm -rf usr/include/c++/

    # Delete GCC runtime artifacts
    rm -rf usr/lib/gcc/
    rm -rf usr/lib/libatomic.so*
    rm -rf usr/lib/libstdc++.so*
fi
