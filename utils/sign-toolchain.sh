#! /usr/bin/env bash
# Copyright 2021-2022 Ryan Hirasaki
# 
# This file is part of OpenSDK
#
# OpenSDK is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# OpenSDK is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with OpenSDK; see the file COPYING. If not see
# <http://www.gnu.org/licenses/>.

die() {
    echo "[FATAL]" "$*" >&2
    exit 1
}

info() {
    echo "[INFO]" "$*"
}

# Change directory to project base
cd "$(dirname "$0")/.." || exit

set -a
ROOT_DIR="${PWD}"
# shellcheck source=../scripts/setup.sh
source "$ROOT_DIR/scripts/setup.sh"
set +a

MAKE="make -C ${ROOT_DIR}/makes/ --no-print-directory"

ARCHIVE_NAME=$(${MAKE} print-pkg)
if [ ! -f "$ROOT_DIR/output/$ARCHIVE_NAME" ]; then
    die "$ARCHIVE_NAME not found in output directory"
fi

if [ ! "$APPLE_DEVELOPER_ID" ]; then
    die "APPLE_DEVELOPER_ID must be set"
fi

if [ "$(uname)" != "Darwin" ]; then
    die "Codesigning is for macOS hosts"
fi

sign_file() {
    local file="$1"
    if ! (file "$file" | grep -q "Mach-O"); then
        return 0
    fi
    info "Signing $file"
    codesign \
        --force \
        --strict \
        --timestamp \
        --options=runtime \
        -s "$APPLE_DEVELOPER_ID" "$file" ||
        die "Could not notarize $file"
}

sign_directory()
{
    find "$1" | while read fname; do
        if [ -f "$fname" ]; then
            sign_file "$fname"
        fi
    done
}

WORKDIR="$(mktemp -d)"
cd "$WORKDIR"

ARCHIVE_FILE="$ROOT_DIR/output/$ARCHIVE_NAME"

tar -xzf "$ARCHIVE_FILE" || die "extraction"

sign_directory "${TOOLCHAIN_NAME}/bin"
sign_directory "${TOOLCHAIN_NAME}/${TARGET_TUPLE}/bin"
sign_directory "${TOOLCHAIN_NAME}/${TARGET_TUPLE}/libexec"

rm "$ARCHIVE_FILE" || die "Cannot delete original toolchain"
tar -czf "$ARCHIVE_FILE" . || die "compression"
cd "$ROOT_DIR"
rm -rf "$WORKDIR"
