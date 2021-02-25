#! /usr/bin/env bash

# Just quit the program if not ran in build.sh
[ -z "$ROOT_DIR" ] && exit

# Exit if something does not look right
SETUP_DIR="$ROOT_DIR/scripts/setup"

source "$SETUP_DIR/tools.sh"
echo "Enabling coreutils"
source "$SETUP_DIR/coreutils.sh"
echo "Processing Build Args"
source "$SETUP_DIR/process_args.sh"
echo "Applying Build Info"
source "$SETUP_DIR/collect_build_info.sh"
echo "Applying MacOS Specifc Flags"
source "$SETUP_DIR/macos.sh"
echo "Applying Linux/Windows Specifc Flags"
source "$SETUP_DIR/linux.sh" # Includes windows
bash "$ROOT_DIR/scripts/confirm_gnu.sh" || exit
bash "$ROOT_DIR/makes/src/test/test.sh" || exit

unset SETUP_DIR
