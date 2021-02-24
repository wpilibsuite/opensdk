#! /usr/bin/env bash

# Just quit the program if not ran in build.sh
[ -z "$ROOT_DIR" ] || exit

# Exit if something does not look right
SETUP_DIR="$ROOT_DIR/scripts/setup"

source "$SETUP_DIR/tools.sh"
source "$SETUP_DIR/coreutils.sh"
source "$SETUP_DIR/process_args.sh"
source "$SETUP_DIR/macos.sh"
source "$SETUP_DIR/linux.sh" # Includes windows
source "$SETUP_DIR/collect_build_info.sh"
bash "$ROOT_DIR/scripts/confirm_gnu.sh" || exit

unset SETUP_DIR
