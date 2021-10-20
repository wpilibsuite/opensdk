#! /usr/bin/env bash

# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh"

if [ "$CANADIAN_STAGE_ONE" = "true" ]; then
    exit 0
fi

PROJECT_EXPORT=(
    sysroot
    binutils
    gcc
    gdb
    frcmake
)

rm -rf tree-{build,install}
mkdir tree-{build,install}
for project in "${PROJECT_EXPORT[@]}"; do
    if ! [ -d "${project}-install" ]; then
        die "${project} install missing"
    fi
    # -L will destroy symlinks and just duplicate
    rsync -aEL \
        "${project}-install/" tree-build/ ||
        die "rsync tree build failed - $project"
done
xpushd tree-build
du -hs .

TREE_OUT="frc${V_YEAR}/${TOOLCHAIN_NAME}/"

rm -rf "${TREE_OUT}"
mkdir -p "${TREE_OUT}"

rsync -aE "./${TARGET_TUPLE}/" "${TREE_OUT}/${TARGET_TUPLE}"
rsync -aE "./${WPI_HOST_PREFIX}/" "${TREE_OUT}"
rm -rf "./${WPI_HOST_PREFIX}" "./${TARGET_TUPLE}"

xpushd "${TREE_OUT}"
rm -rf include share

xpushd bin

if [ -x "${STRIP}" ]; then
    STRIP_CMD="${STRIP}"
elif [ -e "/usr/bin/${HOST_TUPLE}-strip" ]; then
    STRIP_CMD="/usr/bin/${HOST_TUPLE}-strip"
elif [ "${WPI_HOST_NAME}" = "Mac" ]; then
    STRIP_CMD="strip"
else
    die "Cannot find proper strip command"
fi

# Remove any executables that may have the incorrect names
for exec in "${TARGET_TUPLE}-${TARGET_PREFIX}"* "${TARGET_TUPLE}"-gcc-*; do
    rm "${exec}" &>/dev/null || true
done

for exec in *; do
    if file "${exec}" | grep -qiF -e "elf" -e "mach-o" -e "pe32+"; then
        "${STRIP_CMD}" "${exec}" || die "Could not strip ${exec}"
    fi
done

xpopd # bin
du -hs .
xpopd # TREE_OUT
xpopd # tree-build

mv "tree-build/frc${V_YEAR}/" "tree-install/frc${V_YEAR}"
