include $(ROOT_DIR)/consts.env
include $(ROOT_DIR)/targets/${TOOLCHAIN_NAME}/version.env

basic: sysroot-install binutils-install gcc-install cmake-toolchain
extended:

prefix-install:
	sudo mkdir -p "/${WPIPREFIX}"

sysroot: cmake-toolchain
	cd ${BUILD_DIR}; rm -rf sysroot-*
	cd ${BUILD_DIR}/; tar xf ${DOWNLOAD_DIR}/sysroot-libc-linux.tar.bz2
	cd ${BUILD_DIR}/; mkdir -p sysroot-install/
	cd ${BUILD_DIR}/; mv sysroot-libc-linux/ sysroot-install/$(TARGET_TUPLE)

sysroot-install: prefix-install sysroot
	cd ${BUILD_DIR}; sudo cp -r ${BUILD_DIR}/sysroot-install/$(TARGET_TUPLE)/ /$(WPIPREFIX)/

utils:
	cd ${BUILD_DIR}; bash ${ROOT_DIR}/makes/src/utils.sh

binutils-install: utils prefix-install
	cd ${BUILD_DIR}; sudo cp -r ${BUILD_DIR}/binutils-install/${WPIPREFIX}/* /$(WPIPREFIX)/

gcc: sysroot binutils-install
	@# gcc does its own extraction
	cd ${BUILD_DIR}; ${ROOT_DIR}/makes/src/gcc
gcc-install: prefix-install gcc
ifneq (${WPITARGET}, Mac)
	cd ${BUILD_DIR}; sudo cp -r ${BUILD_DIR}/gcc-install/${WPIPREFIX}/* /$(WPIPREFIX)/
endif

cmake-toolchain:
	cd ${BUILD_DIR}; bash ${ROOT_DIR}/makes/src/cmake-toolchain.sh

libcxx: sysroot-install gcc-install cmake-toolchain
	false # TODO

tree:
	cd ${BUILD_DIR}; V_YEAR=$(V_YEAR) V_GCC=$(V_GCC) ${ROOT_DIR}/makes/src/tree

TREEIN_DIRECTORY=${BUILD_DIR}/tree-install/frc$(V_YEAR)/
TREEOUT_TEMPLATE=$(TARGET_PORT)-${TOOLCHAIN_NAME}-$(V_YEAR)-$(WPITARGET)-Toolchain-$(V_GCC)
tarpkg:
	cd ${TREEIN_DIRECTORY}; tar czf ${M}/$(TREEOUT_TEMPLATE).tar.gz .
	cd ${TREEIN_DIRECTORY}; du -h ${M}/$(TREEOUT_TEMPLATE).tar.gz

zippkg:
	cd ${TREEIN_DIRECTORY}; zip -r $(M)/$(TREEOUT_TEMPLATE).zip .
	cd ${TREEIN_DIRECTORY}; du -h $(M)/$(TREEOUT_TEMPLATE).zip

pkg: tree
ifeq ($(WPITARGET), Windows)
	$(MAKE) zippkg
else
	$(MAKE) tarpkg
endif
print-treein:
	@echo ${TREEIN_DIRECTORY}

print-treeout:
	@echo $(TREEOUT_TEMPLATE)

print-pkg:
ifeq ($(WPITARGET), Windows)
	@echo $(TREEOUT_TEMPLATE).zip
else
	@echo $(TREEOUT_TEMPLATE).tar.gz
endif

clean:
	cd ${M}; rm -rf binutils* roborio* sysroot* gcc* tree-install gdb* *-Toolchain-*.tar.gz
