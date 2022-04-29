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
