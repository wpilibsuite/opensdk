#! /usr/bin/env bash

RLINK=readlink
[[ "$OSTYPE" == "darwin"* ]] && RLINK="g$RLINK"

function unpack-deb {
    REPACK_DIR="$1"
    DEB_FILE="$($RLINK -f "$2")"
    OUT_DIR="$(basename "${DEB_FILE/.deb}")"
    cd "$REPACK_DIR"
    mkdir .work_dir/ || exit # fail if dir exists
    pushd .work_dir/
        ar -x "$DEB_FILE"
        mkdir extract/
        pushd extract/
            tar xf ../data.tar.xz
        popd
        rm *.tar.* debian-binary
        mv extract/* .
        rmdir extract/
    popd
    mv .work_dir "${OUT_DIR}"
}

function merge-unpacked-deb {
    REPACK_DIR="$1"
    cd "$1"
    mkdir .work_dir || exit
    UNPACKS=( $(find . -maxdepth 1 -type d | sed 's/.\///g;/^\./d') )
    echo "${UNPACKS[@]}"
    for SINGLE_UNPACK in "${UNPACKS[@]}"; do
        cp -r "$SINGLE_UNPACK"/* .work_dir
        rm -rf "$SINGLE_UNPACK"
    done
    mv .work_dir/* .
    rmdir .work_dir/
}

function fix-headers {
    REPACK_DIR="$1"
    FULL_VER="${2}"
    MAJOR_VER="${FULL_VER/\.*}"

    mv "${REPACK_DIR}"/usr/lib/gcc/aarch64-linux-gnu/{${MAJOR_VER},${FULL_VER}}
    rm "${REPACK_DIR}"/usr/include/aarch64-linux-gnu/c++/${FULL_VER}
    mv "${REPACK_DIR}"/usr/include/aarch64-linux-gnu/c++/{${MAJOR_VER},${FULL_VER}} 
    rm "${REPACK_DIR}"/usr/include/c++/${FULL_VER}
    mv "${REPACK_DIR}"/usr/include/c++/{${MAJOR_VER},${FULL_VER}}
}

function fix-links {
    SYSROOT_DIR="$1"
    pushd "${SYSROOT_DIR}/usr/lib/aarch64-linux-gnu" > /dev/null
    BROKEN_LINKS=( $(find ./ -maxdepth 1 -type l -exec file {} \; | grep broken | sed 's/:.*//g;s/\.\///g') )
    for LIB in "${BROKEN_LINKS[@]}"; do
        link_info="$(readlink "$LIB" | sed 's/\///')"
        link_info_relative="$(realpath --relative-to=. "${SYSROOT_DIR}/${link_info}")"
        [ -f "$link_info_relative" ] || { echo "err $LIB"; continue; }
        echo "$link_info_relative"
        rm "$LIB"
        ln -s "$link_info_relative" "$LIB"
    done
    popd > /dev/null
}
