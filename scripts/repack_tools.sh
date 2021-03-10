#! /usr/bin/env bash

[ -n "${V_GCC+x}" ] || exit
[ -n "${REPACK_DIR+x}" ] || exit
[ -n "${DOWNLOAD_DIR+x}" ] || exit
[ -n "${TARGET_TUPLE+x}" ] || exit

function unpack-generic() {
    DEB_FILE="$(readlink -f "$2")"
    OUT_DIR="$(basename "${DEB_FILE/$1/}")"
    cd "$REPACK_DIR"
    mkdir extract
    pushd extract
    dpkg -x "$DEB_FILE" . || exit
    popd
    mkdir -p "${OUT_DIR}"
    mv extract/* "${OUT_DIR}"
    rmdir extract
}

function unpack-deb() {
    unpack-generic ".deb" "$@"
}

function unpack-ipk() {
    unpack-generic ".ipk" "$@"
}

function merge-unpacked-generic() {
    pushd "$REPACK_DIR"
    mkdir .work_dir || exit
    UNPACKS=($(find . -maxdepth 1 -type d | sed 's/.\///g;/^\./d'))
    echo "${UNPACKS[@]}"
    for SINGLE_UNPACK in "${UNPACKS[@]}"; do
        cp -r "$SINGLE_UNPACK"/* .work_dir
        rm -rf "$SINGLE_UNPACK"
    done
    mv .work_dir/* .
    rmdir .work_dir/
    popd
}

function merge-unpacked-deb() {
    merge-unpacked-generic "$@"
}

function merge-unpacked-ipk() {
    merge-unpacked-generic "$@"
}

function sysroot-clean() {
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

function sysroot-package() {
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
    FULL_VER="${1}"
    MAJOR_VER="${FULL_VER/\.*/}"

    mv "${REPACK_DIR}"/usr/lib/gcc/${TARGET_TUPLE}/{${MAJOR_VER},${FULL_VER}} || true
    rm "${REPACK_DIR}"/usr/include/${TARGET_TUPLE}/c++/${FULL_VER} || true
    mv "${REPACK_DIR}"/usr/include/${TARGET_TUPLE}/c++/{${MAJOR_VER},${FULL_VER}} || true
    rm "${REPACK_DIR}"/usr/include/c++/${FULL_VER} || true
    mv "${REPACK_DIR}"/usr/include/c++/{${MAJOR_VER},${FULL_VER}} || true
}

function fix-links() {
    function find-links() {
        SHARED_OBJS=($(find ./ -name "*.so*" -type l))
        for OBJ in "${SHARED_OBJS[@]}"; do
            DATA="$(file "$OBJ" | grep "broken symbolic link")"
            TARGET_LINK="$(echo "$DATA" | sed "s/.*broken symbolic link to //g")"
            TARGET_LINK="$(echo "$TARGET_LINK" | sed "s/'//g;s/\"//g;s/\`//g")"
            echo "$OBJ;$TARGET_LINK"
            unset TARGET_LINK
        done
    }
    pushd "${REPACK_DIR}"
    BROKEN_LINKS=($(find-links))
    for LIB in "${BROKEN_LINKS[@]}"; do
        SOURCE_LINK="$(echo "$LIB" | sed "s/;.*//g")" # first half
        TARGET_LINK="$(echo "$LIB" | sed "s/.*;//g")" # second half
        link_info_relative="$(realpath --relative-to=. "${REPACK_DIR}/${TARGET_LINK}")"
        if ! [ -f "$link_info_relative" ]; then
            echo "err $SOURCE_LINK, expected $link_info_relative"
            continue
        fi
        echo "$SOURCE_LINK:$link_info_relative"
        rm "$SOURCE_LINK"
        cp "$link_info_relative" "$SOURCE_LINK"
    done
    popd
}

function repack-debian() {
    # REPACK_DIR="$1"
    # DOWNLOAD_DIR="$2"
    # TARGET_TUPLE="$4"
    # V_GCC="$5"

    # clean up old files
    rm -rf "${REPACK_DIR}"
    mkdir -p "${REPACK_DIR}"

    echo "Stage 1: Extract Debs"
    cp *.deb "${REPACK_DIR}"
    for deb in *.deb; do
        echo "$deb"
        unpack-deb "$deb"
    done
    rm "${REPACK_DIR}"/*.deb

    echo "Stage 2: Merge Debs"
    merge-unpacked-deb

    echo "Stage 3: Clean Up Sysroot"
    sysroot-clean

    # echo "Stage 4: Rename tuple"
    # sysroot-tuple-rename \
    #     "${ORIG_TUPLE}" "${TARGET_TUPLE}"

    echo "Stage 4: Clean Up Headers"
    fix-headers "${V_GCC}"

    echo "Stage 5: Fix symlinks"
    fix-links "${REPACK_DIR}/usr/lib/$TARGET_TUPLE"
    #fix-links "${REPACK_DIR}/usr/lib/gcc/$TARGET_TUPLE/${V_GCC}"

    echo "Stage 6: Package"
    sysroot-package
}
