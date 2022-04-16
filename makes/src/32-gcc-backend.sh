#! /usr/bin/env bash

# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh"
source "$(dirname "$0")/utils/conf-gcc.sh"

if is_step_backend; then
    exit 0
fi

gcc_need_lib_build() {
    local lib="${SYSROOT_BUILD_PATH}/usr/lib/$1"
    if [ "$TARGET_LIB_REBUILD" = "true" ]; then
        return 0
    fi
    if compgen -G "${lib}.*" > /dev/null; then
        return 1
    fi
    return 0
}

xcd "${BUILD_DIR}/gcc-build"

TASKS=()
if gcc_need_lib_build libgcc; then
    TASKS+=(
        target-libgcc
    )
fi
if gcc_need_lib_build libatomic; then
    TASKS+=(
        target-libatomic
    )
fi
if gcc_need_lib_build asan || gcc_need_lib_build ubsan; then
    TASKS+=(
        target-libsanitizer
    )
fi
if gcc_need_lib_build libstdc++ && [ "${TARGET_ENABLE_CXX}" = true ]; then
    TASKS+=(
        target-libstdc++-v3
    )
fi
if gcc_need_lib_build libgfortran && [ "${TARGET_ENABLE_FORTRAN}" = true ]; then
    TASKS+=(
        target-libgfortran
    )
fi

for task in "${TASKS[@]}"; do
    gcc_make_multi "$task"
done

if [ -d "${BUILD_DIR}/gcc-install/opt/frc/${TARGET_TUPLE}/lib" ]; then
    # Older versions of GCC want to place target libraries in a different
    # location than what is set via the --libdir option. But binutils
    # still looks for the libraries in the --libdir option. So this causes
    # crossbuilds that require any extra library that was not already
    # present to fail when linking. This is a workaround for that.
    rsync -aEL \
        "${BUILD_DIR}/gcc-install/opt/frc/${TARGET_TUPLE}/lib/" \
        "${BUILD_DIR}/gcc-install/opt/frc/${TARGET_TUPLE}/sysroot/usr/lib/"
    rm -rf "${BUILD_DIR}/gcc-install/opt/frc/${TARGET_TUPLE}/lib"
fi

if [ "${TARGET_LIB_REBUILD}" = "true" ]; then
    # Duplicate the GCC runtime artifacts to a seperate directory
    # so it can later be scp'd to the roboRIO.
    rsync -aEL \
        "${BUILD_DIR}/gcc-install/opt/frc/${TARGET_TUPLE}/sysroot/usr/lib/" \
        "${BUILD_DIR}/gcc-install/opt/frc/${TARGET_TUPLE}/gcclib/"
    # We don't need the static libraries of the GCC runtime
    rm -r "${BUILD_DIR}/gcc-install/opt/frc/${TARGET_TUPLE}/gcclib/gcc"
fi
