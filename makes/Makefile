include $(ROOT_DIR)/consts.env
include $(ROOT_DIR)/targets/${TOOLCHAIN_NAME}/version.env

ifeq ($(WPI_HOST_NAME), Windows)
ARCHIVE_TOOL=zip -r -9
ARCHIVE_SUFFIX=zip
else
ARCHIVE_TOOL=tar -czf
ARCHIVE_SUFFIX=tgz
endif

SHELL := /bin/bash

.SILENT:
.NOTPARALLEL:

$(BUILD_DIR) $(OUTPUT_DIR):
	mkdir -p $@

task/%: $(BUILD_DIR)
	cd ${BUILD_DIR} && $(SHELL) $(ROOT_DIR)/makes/src/$*.sh

TREEIN_DIR=${BUILD_DIR}/tree-install/frc$(V_YEAR)/
TREEOUT_TEMPLATE=$(TARGET_PORT)-${TOOLCHAIN_NAME}-$(V_YEAR)-$(WPI_HOST_TUPLE)-Toolchain-$(V_GCC)

pkg: $(OUTPUT_DIR)
	rm -f $(OUTPUT_DIR)/$(TREEOUT_TEMPLATE).$(ARCHIVE_SUFFIX)
	cd ${TREEIN_DIR} && \
		$(ARCHIVE_TOOL) $(OUTPUT_DIR)/$(TREEOUT_TEMPLATE).$(ARCHIVE_SUFFIX) .
	cd $(OUTPUT_DIR) && \
		du -h $(TREEOUT_TEMPLATE).$(ARCHIVE_SUFFIX)

print-treein:
	echo ${TREEIN_DIR}

print-treeout:
	echo $(TREEOUT_TEMPLATE)

print-pkg:
	echo $(TREEOUT_TEMPLATE).$(ARCHIVE_SUFFIX)
