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
