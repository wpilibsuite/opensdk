#! /usr/bin/bash

# This script is only to cleanup the sysroot if we are
# rebuilding the GCC runtime. Cleanup should only be done
# with the backend build.

source "$(dirname "$0")/common.sh"

xcd "${BUILD_DIR}/sysroot-install/${TARGET_TUPLE}/sysroot"

# Why is this here on the rio?
rm -rf lib/cpp

if [ "${TARGET_LIB_REBUILD}" != "true" ]; then
    exit 0
fi

# Delete libstdc++ headers which will be replaced
rm -rf usr/include/c++/

# Delete GCC runtime artifacts
rm -rf usr/lib/gcc/
rm -rf usr/lib/libatomic.so*
rm -rf usr/lib/libstdc++.so*
