include ${ROOT_DIR}/consts.env
include ${ROOT_DIR}/targets/${TOOLCHAIN_NAME}/version.env

all: clean test-cc sysroot binutils gcc gdb tree tarpkg

sysroot:
	cd ${BUILD_DIR}; rm -rf sysroot-*
ifeq (${TARGET_TUPLE}, roborio)
	cd ${BUILD_DIR}; mkdir -p sysroot-libc-linux/
	cd ${BUILD_DIR}/sysroot-libc-linux; tar xf ${REPACK_DIR}/libc6-frc$(V_YEAR)-armel-cross_$(Va_LIBC).orig.tar.bz2
	cd ${BUILD_DIR}/sysroot-libc-linux; tar xf ${REPACK_DIR}/linux-libc-dev-frc$(V_YEAR)-armel-cross_$(Va_LINUX).orig.tar.bz2
	cd ${BUILD_DIR}/sysroot-libc-linux; tar xf ${REPACK_DIR}/libgcc1-frc$(V_YEAR)-armel-cross_$(Va_LIBGCC).orig.tar.bz2
	cd ${BUILD_DIR}/sysroot-libc-linux; tar xf ${REPACK_DIR}/libstdc++6-frc$(V_YEAR)-armel-cross_$(Va_LIBSTDCPP).orig.tar.bz2
	cd ${BUILD_DIR}; ${ROOT_DIR}/makes/src/sysroot
else
	cd ${BUILD_DIR}/; tar xf ${DOWNLOAD_DIR}/sysroot-libc-linux.tar.bz2
	cd ${BUILD_DIR}/; mkdir -p sysroot-install/
	cd ${BUILD_DIR}/; mv sysroot-libc-linux/ sysroot-install/$(TARGET_TUPLE)
endif

sysroot-install:
	cd ${M}; sudo cp -r ${BUILD_DIR}/sysroot-install/$(TARGET_TUPLE)/ "/usr/local/"

binutils:
	cd ${M}; tar xf ${DOWNLOAD_DIR}/binutils-$(V_BINUTILS).tar.bz2
	cd ${M}; V_YEAR=$(V_YEAR) V_BINUTILS=$(V_BINUTILS) ${ROOT_DIR}/makes/src/binutils
binutils-install:
	cd ${M}; sudo cp -r ${BUILD_DIR}/binutils-install/${WPIPREFIX}/* "/usr/local/"

gcc:
	@# gcc does its own extraction
	cd ${M}; ${ROOT_DIR}/makes/src/gcc
gcc-install:
	cd ${M}; sudo cp -r ${BUILD_DIR}/gcc-install/${WPIPREFIX}/* "/usr/local/"

expat:
	cd ${M}; tar xf ${DOWNLOAD_DIR}/expat-$(Vw_EXPAT).tar.bz2
	cd ${M}; Vw_EXPAT=$(Vw_EXPAT) ${ROOT_DIR}/makes/src/expat

gdb:
	cd ${M}; tar xf ${DOWNLOAD_DIR}/gdb-$(V_GDB).tar.gz
	cd ${M}; V_YEAR=$(V_YEAR) V_GDB=$(V_GDB) ${ROOT_DIR}/makes/src/gdb

tree:
	cd ${M}; V_YEAR=$(V_YEAR) V_GCC=$(V_GCC) ${ROOT_DIR}/makes/src/tree

TREEOUT_TEMPLATE=$(TOOLCHAIN_NAME)-$(V_YEAR)-$(WPITARGET)-Toolchain-$(V_GCC)
tarpkg:
	cd ${M}/tree-install/frc$(V_YEAR); tar czf ${M}/$(TREEOUT_TEMPLATE).tar.gz .

zip:
	cd ${M}/tree-install/frc$(V_YEAR); zip -r $(M)/$(TREEOUT_TEMPLATE).zip .
print-treeout:
	@echo $(TREEOUT_TEMPLATE)

clean:
	cd ${M}; rm -rf binutils* roborio* sysroot* gcc* tree-install gdb* *-Toolchain-*.tar.gz
