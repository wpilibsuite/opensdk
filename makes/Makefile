include $(ROOT_DIR)/consts.env
include $(ROOT_DIR)/targets/${TOOLCHAIN_NAME}/version.env

all: clean toolset-install

clean:
	rm -rf ${BUILD_DIR}
	mkdir -p ${BUILD_DIR}

prefix-install:
	sudo mkdir -p "/${WPI_HOST_PREFIX}"

sysroot: prefix-install
	cd ${BUILD_DIR}; bash ${ROOT_DIR}/makes/src/10-sysroot.sh

sources:
	cd ${BUILD_DIR}; bash ${ROOT_DIR}/makes/src/11-sources.sh

patches: sources
	cd ${BUILD_DIR}; bash ${ROOT_DIR}/makes/src/12-patches.sh

binutils: sources patches prefix-install
	cd ${BUILD_DIR}; bash ${ROOT_DIR}/makes/src/20-binutils.sh

gcc: sources patches sysroot binutils
	cd ${BUILD_DIR}; bash ${ROOT_DIR}/makes/src/30-gcc.sh

expat: sources
	cd ${BUILD_DIR}; bash ${ROOT_DIR}/makes/src/40-expat.sh

gdb: sources patches expat
	cd ${BUILD_DIR}; bash ${ROOT_DIR}/makes/src/41-gdb.sh

frcmake: sources patches
	cd ${BUILD_DIR}; bash ${ROOT_DIR}/makes/src/50-frcmake.sh

toolset: sysroot binutils gcc gdb frcmake

toolset-install: prefix-install toolset
ifneq (${WPI_HOST_NAME}, Mac)
	cd ${BUILD_DIR}; sudo cp -r ${BUILD_DIR}/binutils-install/${WPI_HOST_PREFIX}/* /$(WPI_HOST_PREFIX)
	cd ${BUILD_DIR}; sudo cp -r ${BUILD_DIR}/gcc-install/${WPI_HOST_PREFIX}/* /$(WPI_HOST_PREFIX)
	cd ${BUILD_DIR}; sudo cp -r ${BUILD_DIR}/sysroot-install/* /$(WPI_HOST_PREFIX)
endif

tree:
	cd ${BUILD_DIR}; bash ${ROOT_DIR}/makes/src/tree.sh

TREEIN_DIRECTORY=${BUILD_DIR}/tree-install/frc$(V_YEAR)/
TREEOUT_TEMPLATE=$(TARGET_PORT)-${TOOLCHAIN_NAME}-$(V_YEAR)-$(WPI_HOST_NAME)_$(TARGET_PORT)-Toolchain-$(V_GCC)
tarpkg:
	cd ${TREEIN_DIRECTORY}; XZ_OPT=-T0 tar -c --xz -f ${M}/$(TREEOUT_TEMPLATE).txz .
	cd ${TREEIN_DIRECTORY}; du -h ${M}/$(TREEOUT_TEMPLATE).txz

zippkg:
	cd ${TREEIN_DIRECTORY}; zip -r $(M)/$(TREEOUT_TEMPLATE).zip .
	cd ${TREEIN_DIRECTORY}; du -h $(M)/$(TREEOUT_TEMPLATE).zip

pkg: tree
ifeq ($(WPI_HOST_NAME), Windows)
	$(MAKE) zippkg
else
	$(MAKE) tarpkg
endif
print-treein:
	@echo ${TREEIN_DIRECTORY}

print-treeout:
	@echo $(TREEOUT_TEMPLATE)

print-pkg:
ifeq ($(WPI_HOST_NAME), Windows)
	@echo $(TREEOUT_TEMPLATE).zip
else
	@echo $(TREEOUT_TEMPLATE).txz
endif

clean: