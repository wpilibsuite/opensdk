#! /usr/bin/env bash

function unpack-generic() {
    REPACK_DIR="$3"
    DEB_FILE="$(readlink -f "$4")"
    OUT_DIR="$(basename "${DEB_FILE/$1/}")"
    cd "$REPACK_DIR"
    mkdir .work_dir/ || exit # fail if dir exists
    pushd .work_dir/
    ar -x "$DEB_FILE"
    mkdir extract/
    pushd extract/
    tar xf ../data.tar.$2
    popd
    rm *.tar.* debian-binary
    mv extract/* .
    rmdir extract/
    popd
    mv .work_dir "${OUT_DIR}"
}

function unpack-deb() {
    unpack-generic ".deb" "xz" "$@"
}

function unpack-ipk() {
    unpack-generic ".ipk" "gz" "$@"
}

function merge-unpacked-generic() {
    REPACK_DIR="$1"
    cd "$1"
    mkdir .work_dir || exit
    UNPACKS=($(find . -maxdepth 1 -type d | sed 's/.\///g;/^\./d'))
    echo "${UNPACKS[@]}"
    for SINGLE_UNPACK in "${UNPACKS[@]}"; do
        cp -r "$SINGLE_UNPACK"/* .work_dir
        rm -rf "$SINGLE_UNPACK"
    done
    mv .work_dir/* .
    rmdir .work_dir/
}

function merge-unpacked-deb() {
    merge-unpacked-generic "$@"
}

function merge-unpacked-ipk() {
    merge-unpacked-generic "$@"
}

function sysroot-clean() {
    REPACK_DIR="$1"
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
}

function sysroot-tuple-rename() {
    REPACK_DIR="$1"
    GCC_VERSION="$2"
    OLD_TUPLE="$3"
    NEW_TUPLE="$4"
    pushd "${REPACK_DIR}/usr/lib/"
    mv "$OLD_TUPLE" "$NEW_TUPLE"
    popd # usr/lib/
    pushd "${REPACK_DIR}/usr/lib/gcc/"
    mv "$OLD_TUPLE" "$NEW_TUPLE"
    popd # usr/lib/gcc
    pushd "${REPACK_DIR}/usr/include/c++/${GCC_VERSION}/"
    mv "$OLD_TUPLE" "$NEW_TUPLE"
    popd # usr/include/...
}

function sysroot-package() {
    REPACK_DIR="$1"
    DOWNLOAD_DIR="$2"
    pushd "/tmp"
    echo "download dir ${DOWNLOAD_DIR}"
    rm -rf "${DOWNLOAD_DIR}/sysroot-libc-linux"
    mv "${REPACK_DIR}" "${DOWNLOAD_DIR}/sysroot-libc-linux"
    mkdir "${REPACK_DIR}"
    pushd "${DOWNLOAD_DIR}"
    tar cjf sysroot-libc-linux.tar.bz2 sysroot-libc-linux --owner=0 --group=0
    popd
    popd

}

function fix-headers() {
    REPACK_DIR="$1"
    FULL_VER="${2}"
    MAJOR_VER="${FULL_VER/\.*/}"

    mv "${REPACK_DIR}"/usr/lib/gcc/aarch64-linux-gnu/{${MAJOR_VER},${FULL_VER}}
    rm "${REPACK_DIR}"/usr/include/aarch64-linux-gnu/c++/${FULL_VER}
    mv "${REPACK_DIR}"/usr/include/aarch64-linux-gnu/c++/{${MAJOR_VER},${FULL_VER}}
    rm "${REPACK_DIR}"/usr/include/c++/${FULL_VER}
    mv "${REPACK_DIR}"/usr/include/c++/{${MAJOR_VER},${FULL_VER}}
}

function fix-links() {
    SYSROOT_DIR="$1"
    pushd "${SYSROOT_DIR}/usr/lib/aarch64-linux-gnu" >/dev/null
    BROKEN_LINKS=($(find ./ -maxdepth 1 -type l -exec file {} \; | grep broken | sed 's/:.*//g;s/\.\///g'))
    for LIB in "${BROKEN_LINKS[@]}"; do
        link_info="$(readlink "$LIB" | sed 's/\///')"
        link_info_relative="$(realpath --relative-to=. "${SYSROOT_DIR}/${link_info}")"
        [ -f "$link_info_relative" ] || {
            echo "err $LIB"
            continue
        }
        echo "$link_info_relative"
        rm "$LIB"
        ln -s "$link_info_relative" "$LIB"
    done
    popd >/dev/null
}
