#! /usr/bin/env bash

# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh"

rm -rf backend-install
mkdir -p backend-install/tmp/frc

if [ "$TARGET_LIB_REBUILD" = "true" ]; then
    # Hack to make the linker behave nicely with a out of tree libgcc.
    # This will take double the space on disk but is compressed
    # within the zip/tgz file.
    # TODO: Remove artifact from the old GCC build to cut down on space.
    rsync -aEL \
        "gcc-install/tmp/frc/${TARGET_TUPLE}/gcclib/" \
        "gcc-install/tmp/frc/${TARGET_TUPLE}/sysroot/usr/lib/"
fi

# Build backend archive for use by the frontend builds.
rsync -aEL \
    "sysroot-install/" \
    "backend-install/"
if [ "$TARGET_LIB_REBUILD" = "true" ]; then
    rsync -aEL \
        "gcc-install/tmp/frc/${TARGET_TUPLE}/gcclib" \
        "backend-install/${TARGET_TUPLE}/"
fi
rsync -aEL \
    "gcc-install/tmp/frc/${TARGET_TUPLE}/sysroot" \
    "backend-install/${TARGET_TUPLE}/"

xpushd backend-install
# Build an archive of the custom sysroot
tar -cf "${TARGET_TUPLE}.tar" "${TARGET_TUPLE}"
xpopd

# Place tarball of custom sysroot in the build directory
mv "backend-install/${TARGET_TUPLE}.tar" "."
