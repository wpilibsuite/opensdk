#! /usr/bin/env bash

# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh"
source "$(dirname "$0")/utils/conf-gcc.sh"

if ! is_lib_rebuild_required && [ "$BUILD_BACKEND" = true ]; then
    exit 0
fi

xcd "${BUILD_DIR}/gcc-build"

TASKS=()
if [ "${TARGET_DISTRO}" = "roborio" ]; then
    # libgcc is complicated to work with preexisting artifacts
    # so we just rebuild the runtime for all platforms.
    TASKS+=(
        target-libgcc
        target-libgfortran
        target-libsanitizer
    )
    if [ "${TARGET_LIB_REBUILD}" = "true" ]; then
        # If the build system is intending to use a unsupported compiler
        # then just rebuild all the libraries.
        TASKS+=(
            target-libatomic
            target-libstdc++-v3
        )
    fi
fi

for task in "${TASKS[@]}"; do
    gcc_make_multi "$task"
done

if [ "${TARGET_LIB_REBUILD}" = "true" ]; then
    # Duplicate the GCC runtime artifacts to a seperate directory
    # so it can later be scp'd to the roboRIO.
    rsync -aEL \
        "${BUILD_DIR}/gcc-install/opt/frc/${TARGET_TUPLE}/sysroot/usr/lib/" \
        "${BUILD_DIR}/gcc-install/opt/frc/${TARGET_TUPLE}/gcclib/"
    # We don't need the static libraries of the GCC runtime
    rm -r "${BUILD_DIR}/gcc-install/opt/frc/${TARGET_TUPLE}/gcclib/gcc"
fi
