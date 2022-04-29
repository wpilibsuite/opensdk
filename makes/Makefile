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

include $(ROOT_DIR)/consts.env
include $(ROOT_DIR)/targets/${TOOLCHAIN_NAME}/version.env

SHELL := /bin/bash

.SILENT:
.NOTPARALLEL:

$(BUILD_DIR) $(OUTPUT_DIR):
	mkdir -p $@

task/%: $(BUILD_DIR)
	cd ${BUILD_DIR} && $(SHELL) $(ROOT_DIR)/makes/src/$*.sh

pkg: $(OUTPUT_DIR)
	$(SHELL) $(ROOT_DIR)/makes/src/utils/archive.sh --archive
print-treein:
	$(SHELL) $(ROOT_DIR)/makes/src/utils/archive.sh --print-treein
print-treeout:
	$(SHELL) $(ROOT_DIR)/makes/src/utils/archive.sh --print-treeout
print-pkg:
	$(SHELL) $(ROOT_DIR)/makes/src/utils/archive.sh --print-pkg
