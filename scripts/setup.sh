#! /usr/bin/env bash

# Just quit the program if not ran in build.sh
[ -z "$ROOT_DIR" ] && exit

# Exit if something does not look right
SETUP_DIR="$ROOT_DIR/scripts/setup"

source "$SETUP_DIR/tools.sh"
echo "Processing Build Args"
source "$SETUP_DIR/process_args.sh"
echo "Applying Build Info"
source "$SETUP_DIR/collect_build_info.sh"
if is_builder_mac; then
    echo "Applying MacOS Specifc Options"
    source "$SETUP_DIR/macos.sh"
fi
echo "Finalizing Compiler Flags"
source "$SETUP_DIR/flags.sh"

unset SETUP_DIR
