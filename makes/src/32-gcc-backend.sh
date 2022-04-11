#! /usr/bin/env bash

# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh"
source "$(dirname "$0")/utils/conf-gcc.sh"

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
            libatomic
            libstdc++-v3
        )
    fi
fi

if [ "${TASKS[#]}" = 0 ]; then
    # No work needed
    return 0
fi

for task in "${TASKS[@]}"; do
    gcc_make_multi "$task"
done

if [ "${TARGET_LIB_REBUILD}" = "true" ]; then
    CONFIGURE_GCC+=(
        "--libdir=${gcclib_dir}"
        "--with-slibdir=${gcclib_dir}"
        "--with-toolexeclibdir=${gcclib_dir}"
    )
    process_background "Configuring GCC for duallib" \
        "$DOWNLOAD_DIR/gcc-${V_GCC}/configure" \
        "${CONFIGURE_GCC[@]}" ||
        die "gcc configure failed"

    for task in "${TASKS[@]}"; do
        gcc_make_multi "$task"
    done
fi
