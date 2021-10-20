include $(ROOT_DIR)/consts.env
include $(ROOT_DIR)/targets/${TOOLCHAIN_NAME}/version.env

ifeq ($(WPI_HOST_NAME), Windows)
ARCHIVE_TOOL=zip -r -9
ARCHIVE_SUFFIX=zip
else
ARCHIVE_TOOL=tar -c --xz -f
ARCHIVE_SUFFIX=txz
endif

SHELL := /bin/bash
TASKS := clean \
		task/10-sysroot \
		task/11-sources \
		task/12-patches \
		task/20-binutils \
		task/30-gcc \
		task/40-expat \
		task/41-gdb \
		task/50-frcmake \
		task/99-tree

.PHONY: all
.SILENT:
.NOTPARALLEL:

all: $(TASKS)
ifeq ($(CANADIAN_STAGE_ONE), true)
	sudo mkdir -p $(WPI_HOST_PREFIX)
	sudo cp -r \
		${BUILD_DIR}/binutils-install/$(WPI_HOST_PREFIX)/* \
		${BUILD_DIR}/gcc-install/$(WPI_HOST_PREFIX)/* \
		${BUILD_DIR}/sysroot-install/* \
		$(WPI_HOST_PREFIX)
endif

$(BUILD_DIR) $(OUTPUT_DIR):
	mkdir -p $@

task/%: ${BUILD_DIR}
	cd ${BUILD_DIR} && $(SHELL) $(ROOT_DIR)/makes/src/$*.sh

clean:
	rm -rf ${BUILD_DIR}
	mkdir -p ${BUILD_DIR}

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
