#! /usr/bin/env bash

# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh"

rm -rf tree-{build,install}
mkdir tree-{build,install}
for dir in {gcc,sysroot,binutils,gdb,frcmake}-install; do
    # -L will destroy symlinks and just duplicate
    rsync -aL "$dir/" tree-build
done
xpushd tree-build
du -hs .

TREE_OUT="frc${V_YEAR}/${TOOLCHAIN_NAME}/"

rm -rf "${TREE_OUT}"
mkdir -p "${TREE_OUT}"

rsync -a "./${TARGET_TUPLE}/" "${TREE_OUT}/${TARGET_TUPLE}"
rsync -a "./${WPI_HOST_PREFIX}/" "${TREE_OUT}"
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
    if file "${exec}" | grep -qiF -e "elf" -e "mach-o"; then
        "${STRIP_CMD}" "${exec}" || die "Could not strip ${exec}"
    fi
done

xpopd # bin
du -hs .
xpopd # TREE_OUT
xpopd # tree-build

mv "tree-build/frc${V_YEAR}/" "tree-install/frc${V_YEAR}"
