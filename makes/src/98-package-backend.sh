#! /usr/bin/env bash

# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh"

rm -rf backend-install
mkdir -p backend-install/opt/frc

rsync -aEL \
    "sysroot-install/" \
    "backend-install/opt/frc/"
rsync -aEL \
    "gcc-install/opt/frc/${TARGET_TUPLE}/lib" \
    "gcc-install/opt/frc/${TARGET_TUPLE}/sysroot" \
    "backend-install/opt/frc/${TARGET_TUPLE}"

xpushd backend-install
mv opt/frc/* .
rm -r opt

# Build an archive of the custom sysroot
tar -cf "${TARGET_TUPLE}.tar" "${TARGET_TUPLE}"
xpopd

# Place tarball of custom sysroot in the build directory
mv "backend-install/${TARGET_TUPLE}.tar" "."
