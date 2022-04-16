#! /usr/bin/env bash

# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh"
source "$(dirname "$0")/utils/conf-gcc.sh"

if is_step_backend && ! is_lib_rebuild_required; then
    exit 0
fi

xcd "${BUILD_DIR}/gcc-build"

GCC_TASKS=()
gcc_update_target_list

for task in "${GCC_TASKS[@]}"; do
    gcc_make_multi "$task"
done

if [ -d "${BUILD_DIR}/gcc-install/tmp/frc/${TARGET_TUPLE}/lib" ]; then
    # Older versions of GCC want to place target libraries in a different
    # location than what is set via the --libdir option. But binutils
    # still looks for the libraries in the --libdir option. So this causes
    # crossbuilds that require any extra library that was not already
    # present to fail when linking. This is a workaround for that.
    rsync -aEL \
        "${BUILD_DIR}/gcc-install/tmp/frc/${TARGET_TUPLE}/lib/" \
        "${BUILD_DIR}/gcc-install/tmp/frc/${TARGET_TUPLE}/sysroot/usr/lib/"
    rm -rf "${BUILD_DIR}/gcc-install/tmp/frc/${TARGET_TUPLE}/lib"
fi

if [ "${TARGET_LIB_REBUILD}" = "true" ]; then
    # Duplicate the GCC runtime artifacts to a seperate directory
    # so it can later be scp'd to the roboRIO.
    rsync -aEL \
        "${BUILD_DIR}/gcc-install/tmp/frc/${TARGET_TUPLE}/sysroot/usr/lib/" \
        "${BUILD_DIR}/gcc-install/tmp/frc/${TARGET_TUPLE}/gcclib/"
    # We don't need the static libraries of the GCC runtime
    rm -r "${BUILD_DIR}/gcc-install/tmp/frc/${TARGET_TUPLE}/gcclib/gcc"
fi
