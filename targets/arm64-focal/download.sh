#! /usr/bin/env bash

source "$(dirname "$0")/version.env" || exit
source "$(dirname "$0")/../../scripts/downloads_tools.sh" || exit

signed sig https://ftp.gnu.org/gnu/gcc/gcc-${V_GCC}/gcc-${V_GCC}.tar.gz
signed sig https://ftp.gnu.org/gnu/binutils/binutils-${V_BIN}.tar.bz2
signed sig https://ftp.gnu.org/gnu/gdb/gdb-${V_GDB}.tar.gz

POOL="http://ports.ubuntu.com/pool/main/"
POOL_UNIVERSE="http://ports.ubuntu.com/pool/universe/"
basic-download $POOL_UNIVERSE/g/gcc-10/libgcc1_${Va_LIBGCC}_arm64.deb
basic-download $POOL/g/gcc-10/libgcc-10-dev_${Va_LIBGCC}_arm64.deb
basic-download $POOL/g/gcc-10/libatomic1_${Va_LIBSTDCPP}_arm64.deb
basic-download $POOL/g/gcc-10/libstdc++6_${Va_LIBSTDCPP}_arm64.deb
basic-download $POOL_UNIVERSE/g/gcc-10/libstdc++-10-dev_${Va_LIBSTDCPP}_arm64.deb
basic-download $POOL/g/gcc-10/libasan6_${Va_LIBSTDCPP}_arm64.deb
basic-download $POOL/g/gcc-10/liblsan0_${Va_LIBSTDCPP}_arm64.deb
basic-download $POOL/g/gcc-10/libtsan0_${Va_LIBSTDCPP}_arm64.deb
basic-download $POOL/g/gcc-10/libgomp1_${Va_LIBSTDCPP}_arm64.deb
basic-download $POOL/g/gcc-10/libubsan1_${Va_LIBSTDCPP}_arm64.deb
basic-download $POOL/g/gcc-10/libitm1_${Va_LIBSTDCPP}_arm64.deb
basic-download $POOL/g/glibc/libc6_${Va_LIBC}_arm64.deb
basic-download $POOL/g/glibc/libc6-dev_${Va_LIBC}_arm64.deb
basic-download $POOL/l/linux/linux-libc-dev_${Va_LINUX}_arm64.deb
