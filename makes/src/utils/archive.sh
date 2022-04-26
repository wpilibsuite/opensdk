#! /usr/bin/env bash

# January 1, 2000. Midnight.
EPOCH="946684800"

TREEIN_DIR="${BUILD_DIR}/tree-install/frc${V_YEAR}/"
TREEOUT_TEMPLATE="${TARGET_PORT}-${TOOLCHAIN_NAME}-${V_YEAR}-${WPI_HOST_TUPLE}-Toolchain-${V_GCC}"

nondeterministic() {
    if ! command -v strip-nondeterminism >/dev/null; then
        return
    fi
    # This should make all files in the toolchain have the same
    # timestamp so we can better compare builds.
    strip-nondeterminism -T "$EPOCH" "$1"
}

archive_win() {
    rm -f "${OUTPUT_DIR}/$TREEOUT_TEMPLATE.zip"
    zip -r -9 "${OUTPUT_DIR}/$TREEOUT_TEMPLATE.zip" .
    nondeterministic "${OUTPUT_DIR}/$TREEOUT_TEMPLATE.zip"
}

archive_nix() {
    rm -f "${OUTPUT_DIR}/$TREEOUT_TEMPLATE.tgz"
    tar -cf "${OUTPUT_DIR}/$TREEOUT_TEMPLATE.tar" .
    nondeterministic "${OUTPUT_DIR}/$TREEOUT_TEMPLATE.tar"
    gzip "${OUTPUT_DIR}/$TREEOUT_TEMPLATE.tar"
    mv "${OUTPUT_DIR}/$TREEOUT_TEMPLATE.tar.gz" "${OUTPUT_DIR}/$TREEOUT_TEMPLATE.tgz"
}

archive() {
    xcd "${TREEIN_DIR}"
    if [ "${WPI_HOST_NAME}" = Windows ]; then
        archive_win || return
    else
        archive_nix || return
    fi
}

argparse() {
    while [ $# -gt 0 ]; do
        case "$1" in
            --archive)
                archive
                exit
                ;;
            --print-treein)
                echo "$TREEIN_DIR"
                exit
                ;;
            --print-treeout)
                echo "$TREEOUT_TEMPLATE"
                exit
                ;;
            --print-pkg)
                if [ "${WPI_HOST_NAME}" = Windows ]; then
                    echo "${TREEOUT_TEMPLATE}.zip"
                else
                    echo "${TREEOUT_TEMPLATE}.tgz"
                fi
                exit
                ;;
        esac
        shift
    done
}

argparse "$@"
