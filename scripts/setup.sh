#! /usr/bin/env bash

# Just quit the program if not ran in build.sh
[ -z "$ROOT_DIR" ] && exit

# Exit if something does not look right
SETUP_DIR="$ROOT_DIR/scripts/setup"

source "$SETUP_DIR/tools.sh"
echo "Enabling GNUtils"
source "$SETUP_DIR/gnutils.sh"
echo "Processing Build Args"
source "$SETUP_DIR/process_args.sh"
echo "Applying Build Info"
source "$SETUP_DIR/collect_build_info.sh"
echo "Applying MacOS Specifc Flags"
source "$SETUP_DIR/macos.sh"
echo "Applying Linux/Windows Specifc Flags"
source "$SETUP_DIR/linux.sh" # Includes windows
echo "Finalizing Compiler Flags"
source "$SETUP_DIR/flags.sh"
bash "$ROOT_DIR/scripts/confirm_gnu.sh" || exit
if [ "$WPITARGET" != "sysroot" ]; then
    bash "$ROOT_DIR/makes/src/test/test.sh" || exit
fi

unset SETUP_DIR
