include $(ROOT_DIR)/consts.env
include $(ROOT_DIR)/targets/${TOOLCHAIN_NAME}/version.env

basic: sysroot-install binutils-install gcc-install
extended: gdb

all: clean test-cc sysroot binutils gcc gdb tree tarpkg

sysroot:
	cd ${BUILD_DIR}; rm -rf sysroot-*
	cd ${BUILD_DIR}/; tar xf ${DOWNLOAD_DIR}/sysroot-libc-linux.tar.bz2
	cd ${BUILD_DIR}/; mkdir -p sysroot-install/
	cd ${BUILD_DIR}/; mv sysroot-libc-linux/ sysroot-install/$(TARGET_TUPLE)

sysroot-install: sysroot
ifneq (${WPITARGET}, Windows)
	cd ${BUILD_DIR}; sudo cp -r ${BUILD_DIR}/sysroot-install/$(TARGET_TUPLE)/ "/$(WPIPREFIX)/"
endif

binutils: sysroot
	cd ${BUILD_DIR}; tar xf ${DOWNLOAD_DIR}/binutils-$(V_BINUTILS).tar.bz2
	cd ${BUILD_DIR}; V_YEAR=$(V_YEAR) V_BINUTILS=$(V_BINUTILS) ${ROOT_DIR}/makes/src/binutils
binutils-install: binutils
ifneq (${WPITARGET}, Windows)
	cd ${BUILD_DIR}; sudo cp -r ${BUILD_DIR}/binutils-install/${WPIPREFIX}/* "/$(WPIPREFIX)/"
endif

gcc: sysroot binutils
	@# gcc does its own extraction
	cd ${BUILD_DIR}; ${ROOT_DIR}/makes/src/gcc
gcc-install: gcc
ifneq (${WPITARGET}, Windows)
	cd ${BUILD_DIR}; sudo cp -r ${BUILD_DIR}/gcc-install/${WPIPREFIX}/* "/$(WPIPREFIX)/"
endif

gdb:
	cd ${BUILD_DIR}; tar xf ${DOWNLOAD_DIR}/gdb-$(V_GDB).tar.gz
	cd ${BUILD_DIR}; V_YEAR=$(V_YEAR) V_GDB=$(V_GDB) ${ROOT_DIR}/makes/src/gdb

tree:
	cd ${BUILD_DIR}; V_YEAR=$(V_YEAR) V_GCC=$(V_GCC) ${ROOT_DIR}/makes/src/tree

TREEOUT_TEMPLATE=$(TOOLCHAIN_NAME)-$(V_YEAR)-$(WPITARGET)-Toolchain-$(V_GCC)
tarpkg:
	cd ${BUILD_DIR}/tree-install/frc$(V_YEAR); tar czf ${M}/$(TREEOUT_TEMPLATE).tar.gz .
	cd ${BUILD_DIR}/tree-install/frc$(V_YEAR); du -h ${M}/$(TREEOUT_TEMPLATE).tar.gz

zippkg:
	cd ${BUILD_DIR}/tree-install/frc$(V_YEAR); zip -r $(M)/$(TREEOUT_TEMPLATE).zip .
	cd ${BUILD_DIR}/tree-install/frc$(V_YEAR); du -h $(M)/$(TREEOUT_TEMPLATE).zip

pkg: tree
ifeq ($(WPITARGET), Windows)
	$(MAKE) zippkg
else
	$(MAKE) tarpkg
endif

print-treeout:
	@echo $(TREEOUT_TEMPLATE)

clean:
	cd ${M}; rm -rf binutils* roborio* sysroot* gcc* tree-install gdb* *-Toolchain-*.tar.gz
