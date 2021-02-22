#! /usr/bin/env bash

set -e
SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/version.env" || exit
source "$SCRIPT_DIR/../../scripts/repack_tools.sh" || exit

THIS_DIR="$PWD"
REPACK_DIR="$1"

# clean up old files
rm -rf "${REPACK_DIR}"

if [[ `gcc -dumpmachine` == *apple* ]]
then
	echo "Aliasing ar and tar to use GNU variants gar and gtar..."
	alias ar=/usr/local/opt/binutils/bin/gar
	alias tar=gtar
fi

# Stage 1: Extract Debs
mkdir -p "${REPACK_DIR}"
cp *.deb "${REPACK_DIR}"
for deb in *.deb; do
    echo "$deb"
    unpack-deb "${REPACK_DIR}" "$deb"
done
rm "${REPACK_DIR}"/*.deb

# Stage 2: Merge Debs
merge-unpacked-deb "${REPACK_DIR}"

# Stage 3: Clean Up Sysroot
rm -rf "${REPACK_DIR}"/etc
rm -rf "${REPACK_DIR}"/bin
rm -rf "${REPACK_DIR}"/sbin
rm -rf "${REPACK_DIR}"/libexec
rm -rf "${REPACK_DIR}"/usr/bin
rm -rf "${REPACK_DIR}"/usr/sbin
rm -rf "${REPACK_DIR}"/usr/share
rm -rf "${REPACK_DIR}"/usr/libexec
rm -rf "${REPACK_DIR}"/etc
# remove all empty dirs (semi-recursive)
find "${REPACK_DIR}" -empty -type d -delete

# Stage 4: Clean Up Headers
fix-headers "${REPACK_DIR}" "${V_GCC}"

# Stage 5: Fix symlinks
fix-links "${REPACK_DIR}" "${REPACK_DIR}"/usr/lib/$TARGET_TUPLE
fix-links "${REPACK_DIR}" "${REPACK_DIR}"/usr/lib/gcc/$TARGET_TUPLE/${V_GCC}

# Stage 6: Patch in relative paths
# pushd "${REPACK_DIR}"/usr/lib/aarch64-linux-gnu
# SED="sed -i"
# [[ `gcc -dumpmachine` == *apple* ]] && SED="$SED ''"

# $SED -e "s/\/usr\/lib\/{$TARGET_TUPLE}\///g" libc.so
# $SED -e 's/\/lib\//..\/..\/..\/lib\//g' libc.so
# $SED -e "s/\/usr\/lib\/${TARGET_TUPLE}\///g" libpthread.so
# $SED -e 's/\/lib\//..\/..\/..\/lib\//g' libpthread.so
# popd

# Stage 7: Package
pushd "/tmp"
    echo "download dir ${DOWNLOAD_DIR}"
    rm -rf "${DOWNLOAD_DIR}/sysroot-libc-linux"
	mv "${REPACK_DIR}" "${DOWNLOAD_DIR}/sysroot-libc-linux"
    mkdir "${REPACK_DIR}"
    pushd "${DOWNLOAD_DIR}"
	    tar cjf sysroot-libc-linux.tar.bz2 sysroot-libc-linux --owner=0 --group=0
    popd
popd
