include $(ROOT_DIR)/consts.env
include $(ROOT_DIR)/targets/${TOOLCHAIN_NAME}/version.env

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
.ONESHELL:
.NOTPARALLEL:

all: $(TASKS)
ifeq ($(CANADIAN_STAGE_ONE), true)
	cd ${BUILD_DIR}
	sudo mkdir -p $(WPI_HOST_PREFIX)
	sudo cp -r binutils-install/$(WPI_HOST_PREFIX)/* $(WPI_HOST_PREFIX)
	sudo cp -r gcc-install/$(WPI_HOST_PREFIX)/* $(WPI_HOST_PREFIX)
	sudo cp -r sysroot-install/* $(WPI_HOST_PREFIX)
endif

TASK_DIR := $(ROOT_DIR)/makes/src
task/%:
	mkdir -p ${BUILD_DIR}
	sudo mkdir -p /${WPI_HOST_PREFIX}
	cd ${BUILD_DIR} && $(SHELL) $(TASK_DIR)/$*.sh

clean:
	rm -rf ${BUILD_DIR}
	mkdir -p ${BUILD_DIR}

${OUTPUT_DIR}:
	mkdir -p $@

TREEIN_DIRECTORY=${BUILD_DIR}/tree-install/frc$(V_YEAR)/
TREEOUT_TEMPLATE=$(TARGET_PORT)-${TOOLCHAIN_NAME}-$(V_YEAR)-$(WPI_HOST_TUPLE)-Toolchain-$(V_GCC)
tarpkg: $(OUTPUT_DIR)
	cd ${TREEIN_DIRECTORY}
	tar -c --xz -f $(OUTPUT_DIR)/$(TREEOUT_TEMPLATE).txz .
	cd $(OUTPUT_DIR)
	du -h $(TREEOUT_TEMPLATE).txz

zippkg: $(OUTPUT_DIR)
	cd ${TREEIN_DIRECTORY}
	zip -r $(OUTPUT_DIR)/$(TREEOUT_TEMPLATE).zip .
	cd $(OUTPUT_DIR)
	du -h $(TREEOUT_TEMPLATE).zip

pkg:
ifeq ($(WPI_HOST_NAME), Windows)
	$(MAKE) zippkg
else
	$(MAKE) tarpkg
endif
print-treein:
	echo ${TREEIN_DIRECTORY}

print-treeout:
	echo $(TREEOUT_TEMPLATE)

print-pkg:
ifeq ($(WPI_HOST_NAME), Windows)
	echo $(TREEOUT_TEMPLATE).zip
else
	echo $(TREEOUT_TEMPLATE).txz
endif
