#! /usr/bin/env bash

source "$(dirname "$0")/version.env" || exit
source "$(dirname "$0")/version.${TARGET_PORT}.env" || exit
source "${SCRIPT_DIR}/downloads_tools.sh" || exit

signed sig https://ftp.gnu.org/gnu/gcc/gcc-${V_GCC}/gcc-${V_GCC}.tar.gz

# signed asc https://download.ni.com/ni-linux-rt/feeds/2019/arm/cortexa9-vfpv3/Packages
# Cannot find public key to verify Packages.asc in directory, use https instead
basic-download https://download.ni.com/ni-linux-rt/feeds/2019/arm/cortexa9-vfpv3/Packages || exit 1

signed-ni http://download.ni.com/ni-linux-rt/feeds/2019/arm/cortexa9-vfpv3/gcc_${Va_GCC}_cortexa9-vfpv3.ipk
signed-ni http://download.ni.com/ni-linux-rt/feeds/2019/arm/cortexa9-vfpv3/libgcc1_${Va_LIBGCC}_cortexa9-vfpv3.ipk
signed-ni http://download.ni.com/ni-linux-rt/feeds/2019/arm/cortexa9-vfpv3/libgcc-s-dbg_${Va_LIBGCC}_cortexa9-vfpv3.ipk
signed-ni http://download.ni.com/ni-linux-rt/feeds/2019/arm/cortexa9-vfpv3/libgcc-s-dev_${Va_LIBGCC}_cortexa9-vfpv3.ipk
signed-ni http://download.ni.com/ni-linux-rt/feeds/2019/arm/cortexa9-vfpv3/libstdc++6_${Va_LIBGCC}_cortexa9-vfpv3.ipk
signed-ni http://download.ni.com/ni-linux-rt/feeds/2019/arm/cortexa9-vfpv3/libstdc++-dev_${Va_LIBGCC}_cortexa9-vfpv3.ipk
signed-ni http://download.ni.com/ni-linux-rt/feeds/2019/arm/cortexa9-vfpv3/libatomic1_${Va_LIBGCC}_cortexa9-vfpv3.ipk
signed-ni http://download.ni.com/ni-linux-rt/feeds/2019/arm/cortexa9-vfpv3/libatomic-dev_${Va_LIBGCC}_cortexa9-vfpv3.ipk
signed-ni http://download.ni.com/ni-linux-rt/feeds/2019/arm/cortexa9-vfpv3/libgomp1_${Va_LIBGCC}_cortexa9-vfpv3.ipk
signed-ni http://download.ni.com/ni-linux-rt/feeds/2019/arm/cortexa9-vfpv3/libgomp-dev_${Va_LIBGCC}_cortexa9-vfpv3.ipk
signed-ni http://download.ni.com/ni-linux-rt/feeds/2019/arm/cortexa9-vfpv3/libitm1_${Va_LIBGCC}_cortexa9-vfpv3.ipk
signed-ni http://download.ni.com/ni-linux-rt/feeds/2019/arm/cortexa9-vfpv3/libitm-dev_${Va_LIBGCC}_cortexa9-vfpv3.ipk
signed-ni http://download.ni.com/ni-linux-rt/feeds/2019/arm/cortexa9-vfpv3/libssp0_${Va_LIBGCC}_cortexa9-vfpv3.ipk
signed-ni http://download.ni.com/ni-linux-rt/feeds/2019/arm/cortexa9-vfpv3/libssp-dev_${Va_LIBGCC}_cortexa9-vfpv3.ipk
signed-ni http://download.ni.com/ni-linux-rt/feeds/2019/arm/cortexa9-vfpv3/gcc-runtime-dbg_${Va_LIBGCC}_cortexa9-vfpv3.ipk
signed-ni http://download.ni.com/ni-linux-rt/feeds/2019/arm/cortexa9-vfpv3/libc6_${Va_LIBC}_cortexa9-vfpv3.ipk
signed-ni http://download.ni.com/ni-linux-rt/feeds/2019/arm/cortexa9-vfpv3/libc6-dbg_${Va_LIBC}_cortexa9-vfpv3.ipk
signed-ni http://download.ni.com/ni-linux-rt/feeds/2019/arm/cortexa9-vfpv3/libc6-dev_${Va_LIBC}_cortexa9-vfpv3.ipk
signed-ni http://download.ni.com/ni-linux-rt/feeds/2019/arm/cortexa9-vfpv3/linux-libc-headers-dev_${Va_LINUX}_cortexa9-vfpv3.ipk
signed-ni http://download.ni.com/ni-linux-rt/feeds/2019/arm/cortexa9-vfpv3/libcidn1_${Va_LIBC}_cortexa9-vfpv3.ipk
signed-ni http://download.ni.com/ni-linux-rt/feeds/2019/arm/cortexa9-vfpv3/libc6-thread-db_${Va_LIBC}_cortexa9-vfpv3.ipk
signed-ni http://download.ni.com/ni-linux-rt/feeds/2019/arm/cortexa9-vfpv3/libc6-extra-nss_${Va_LIBC}_cortexa9-vfpv3.ipk

rm Packages