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
elif command -v "${HOST_TUPLE}" &>/dev/null; then
    STRIP_CMD="${HOST_TUPLE}-strip"
else
    STRIP_CMD="strip"
fi

# Remove any executables that may have the incorrect names
for exec in "${TARGET_TUPLE}-${TARGET_PREFIX}"* "${TARGET_TUPLE}"-gcc-*; do
    rm "${exec}" &>/dev/null || true
done

for exec in *; do
    if file "${exec}" | grep -q "script"; then
        # Skip scripts
        continue
    fi
    # "${STRIP_CMD}" "${exec}" || die "Host binary strip failed"
done

xpopd # bin
du -hs .
xpopd # TREE_OUT
xpopd # tree-build

mv "tree-build/frc${V_YEAR}/" "tree-install/frc${V_YEAR}"
