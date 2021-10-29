#! /usr/bin/env bash
# shellcheck disable=SC1090

# Always ensure proper path
cd "$(dirname "$0")" || exit

die() {
    echo "[ERROR] $*"
    exit 1
}

ROOT_DIR="${PWD}"
source "${ROOT_DIR}/scripts/setup/tools.sh"
source "${ROOT_DIR}/scripts/setup/gnutils.sh"

TARGET_CFG="$(readlink -f "$1")"
TARGET_PORT="$2"
TOOLCHAIN_NAME="$(basename "$TARGET_CFG")"
export ROOT_DIR TARGET_CFG TARGET_PORT TOOLCHAIN_NAME

set -a
source "${ROOT_DIR}/consts.env"
source "${ROOT_DIR}/targets/${TOOLCHAIN_NAME}/version.env"
source "${ROOT_DIR}/targets/${TOOLCHAIN_NAME}/info.env"
source "${ROOT_DIR}/targets/${TOOLCHAIN_NAME}/info.${TARGET_PORT}.env"
set +a

LIPO=""
if command -v "lipo"; then
    LIPO=lipo
elif command -v "llvm-lipo"; then
    LIPO=llvm-lipo
else
    echo "[ERROR] lipo not found"
    exit 1
fi

MAKE="make -C ${ROOT_DIR}/makes/"
ARM_MAKE="$MAKE WPI_HOST_TUPLE=arm64-apple-darwin"
X86_MAKE="$MAKE WPI_HOST_TUPLE=x86_64-apple-darwin"
UNIVERSAL_MAKE="$MAKE WPI_HOST_TUPLE=universal-apple-darwin"

ARM_ARCHIVE="$ROOT_DIR/output/$(${ARM_MAKE} --no-print-directory print-pkg)"
X86_ARCHIVE="$ROOT_DIR/output/$(${X86_MAKE} --no-print-directory print-pkg)"

if ! [ -e "$ARM_ARCHIVE" ]; then
    die "Cannot find $ARM_ARCHIVE"
elif ! [ -e "$X86_ARCHIVE" ]; then
    die "Cannot find $X86_ARCHIVE"
fi

rm -rf "/tmp/toolchain-builder"
mkdir "/tmp/toolchain-builder"


cd "/tmp/toolchain-builder" || die "cd"
mkdir arm x86 universal

(cd "arm" && tar xf "$ARM_ARCHIVE") || die "arm extract failed"
(cd "x86" && tar xf "$X86_ARCHIVE") || die "x86 extract failed"

pushd "${ROOT_DIR}/output" || die "pushd"
rm -r ./*
popd || die "popd"

# The stat command has a different interface on Mac and Linux
case "$(uname)" in
Linux) STAT="stat -c %a";;
Darwin) STAT="stat -f %p";;
esac

# Recreate folder structure
(cd x86 && find . -type d) | while read -r FILE; do
    mkdir -p "universal/${FILE}"
    PERM=$($STAT "x86/${FILE}")
    chmod "$PERM" "universal/${FILE}"
done

# Scan the primary tree for files and make them in the output
(cd x86 && find . -type f) | while read -r FILE; do
    TYPE=$($LIPO -info "x86/${FILE}" 2>/dev/null)
    if [[ "$TYPE" =~ "Non-fat" ]]; then # It's a binary
        $LIPO -create "x86/$FILE" "arm/$FILE" -output "universal/$FILE"
    else
        cp "x86/$FILE" "universal/$FILE"
    fi  
    PERM=$($STAT "x86/$FILE")
    chmod "$PERM" "universal/$FILE"
done

ARCHIVE="$(${UNIVERSAL_MAKE} --no-print-directory print-pkg)"
OUTPUT_DIR="${ROOT_DIR}/output"
ARCHIVE_PATH="${OUTPUT_DIR}/${ARCHIVE}"

cd universal || die "cd"
tar -c --xz -f "${ARCHIVE_PATH}" . || die "tar"
