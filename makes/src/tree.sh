#! /usr/bin/env bash

# shellcheck source=./common.sh
source "$(dirname "$0")/common.sh"

rm -rf tree-{build,install}
mkdir tree-{build,install}
for dir in {gcc,sysroot,binutils,gdb,frcmake}-install; do
    echo "$dir/"
    rsync "$dir/" tree-build -a --copy-links
done
xpushd tree-build
du -hs .

WPI_TREE_OUT="frc${V_YEAR}/${TOOLCHAIN_NAME}/"

rm -rf "${WPI_TREE_OUT}"
mkdir -p "${WPI_TREE_OUT}"

rsync -a "./${TARGET_TUPLE}/" "${WPI_TREE_OUT}/${TARGET_TUPLE}"
rsync -a "./${WPI_HOST_PREFIX}/" "${WPI_TREE_OUT}/"
rm -rf "./${WPI_HOST_PREFIX}/"

xpushd "${WPI_TREE_OUT}"
rm -rf include/
rm -rf share/info share/man
rm -rf lib/xtables

du -hs .

xpopd # frcYYYY/
xpopd # tree-build

mv "tree-build/frc${V_YEAR}/" "tree-install/frc${V_YEAR}"
