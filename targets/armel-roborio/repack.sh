#! /usr/bin/env bash

# TODO: Merge these
SCRIPT_DIR="$(dirname "$0")"
WORK_DIR="$1"
REPACK_DIR="$1"

set -e -x

source "$SCRIPT_DIR/version.env" || exit

# clean up old files
rm -rf "${REPACK_DIR}"

if [[ $($CC -dumpmachine) == *apple* ]]
then
	echo "Aliasing ar and tar to use GNU variants gar and gtar..."
	alias ar=/usr/local/opt/binutils/bin/gar
	alias tar=gtar
fi

mkdir -p "${REPACK_DIR}"/{libc6,libc6-dev,linux-libc-headers-dev,libgcc1,libgcc-dev,libstdc\+\+6,libstdc\+\+6-dev}/out
cp linux-libc-headers-dev_${Va_LINUX}_cortexa9-vfpv3.ipk "${REPACK_DIR}"/linux-libc-headers-dev/
cp libc6_${Va_LIBC}_cortexa9-vfpv3.ipk "${REPACK_DIR}"/libc6/
cp libgcc1_${Va_LIBGCC}_cortexa9-vfpv3.ipk "${REPACK_DIR}"/libgcc1/
cp \
    libgcc-s-dbg_${Va_LIBGCC}_cortexa9-vfpv3.ipk \
    libgcc-s-dev_${Va_LIBGCC}_cortexa9-vfpv3.ipk \
    "${REPACK_DIR}"/libgcc-dev/
cp \
    libstdc++6_${Va_LIBSTDCPP}_cortexa9-vfpv3.ipk \
    libatomic1_${Va_LIBSTDCPP}_cortexa9-vfpv3.ipk \
    libgomp1_${Va_LIBSTDCPP}_cortexa9-vfpv3.ipk \
    libitm1_${Va_LIBSTDCPP}_cortexa9-vfpv3.ipk \
    libssp0_${Va_LIBSTDCPP}_cortexa9-vfpv3.ipk \
    "${REPACK_DIR}"/libstdc++6/
cp \
    libstdc++-dev_${Va_LIBSTDCPP}_cortexa9-vfpv3.ipk \
    libatomic-dev_${Va_LIBSTDCPP}_cortexa9-vfpv3.ipk \
    libgomp-dev_${Va_LIBSTDCPP}_cortexa9-vfpv3.ipk \
    libitm-dev_${Va_LIBSTDCPP}_cortexa9-vfpv3.ipk \
    libssp-dev_${Va_LIBSTDCPP}_cortexa9-vfpv3.ipk \
    gcc-runtime-dbg_${Va_LIBSTDCPP}_cortexa9-vfpv3.ipk \
    "${REPACK_DIR}"/libstdc++6-dev/
# the rest are in libc6-dev
cp *.ipk "${REPACK_DIR}"/libc6-dev/

for dir in libc6 libc6-dev linux-libc-headers-dev libgcc1 libgcc-dev libstdc\+\+6 libstdc\+\+6-dev; do
	pushd "${REPACK_DIR}"/$dir
		for file in *.ipk; do
			ar x $file

			# don't need these
			rm control.tar.gz debian-binary
			pushd out
				tar xf ../data.tar.gz
			popd
			# clean up
			rm data.tar.gz
			cp $file "$WORK_DIR/"
		done
	popd
done

# ick... these are everywhere. remove them
find "${REPACK_DIR}" \( -name .install -o -name ..install.cmd \) -delete
# we don't need arm binaries...
rm "${REPACK_DIR}"/libc6/out/sbin/ldconfig
rm "${REPACK_DIR}"/libc6/out/etc/ld.so.conf
rm -rf "${REPACK_DIR}"/libc6-dev/out/sbin
rm -rf "${REPACK_DIR}"/libc6-dev/out/usr/bin
rm -rf "${REPACK_DIR}"/libc6-dev/out/usr/sbin
rm -rf "${REPACK_DIR}"/libc6-dev/out/usr/libexec
# remove all empty dirs (semi-recursive)
find "${REPACK_DIR}" -empty -type d -delete
# move the arm-nilrt libs to arm-frcYEAR
mv "${REPACK_DIR}"/libgcc-dev/out/usr/lib/arm-nilrt-linux-gnueabi "${REPACK_DIR}"/libgcc-dev/out/usr/lib/arm-frc${V_YEAR}-linux-gnueabi
# copy the arm-nilrt headers to arm-frcYEAR
# (we copy instead of move so gdb can find the originals)
cp -Rp "${REPACK_DIR}"/libc6-dev/out/usr/lib/gcc/arm-nilrt-linux-gnueabi "${REPACK_DIR}"/libc6-dev/out/usr/lib/gcc/arm-frc${V_YEAR}-linux-gnueabi
cp -Rp "${REPACK_DIR}"/libstdc++6-dev/out/usr/include/c++/${V_GCC}/arm-nilrt-linux-gnueabi "${REPACK_DIR}"/libstdc++6-dev/out/usr/include/c++/${V_GCC}/arm-frc${V_YEAR}-linux-gnueabi

pushd "${REPACK_DIR}"/linux-libc-headers-dev/
	mv out linux-libc-${Va_LINUX}
	tar cjf "${WORK_DIR}/linux-libc-dev-frc${V_YEAR}-armel-cross_${Va_LINUX}.orig.tar.bz2" * --owner=0 --group=0
popd
pushd "${REPACK_DIR}"/libc6/
	mkdir libc6-${Va_LIBC}
	mv out libc6-${Va_LIBC}/libc6
	mv ../libc6-dev/out libc6-${Va_LIBC}/libc6-dev
	tar cjf "${WORK_DIR}/libc6-frc${V_YEAR}-armel-cross_${Va_LIBC}.orig.tar.bz2" * --owner=0 --group=0
popd
pushd "${REPACK_DIR}"/libgcc1/
	mkdir libgcc1-${Va_LIBGCC}
	mv out libgcc1-${Va_LIBGCC}/libgcc1
	mv ../libgcc-dev/out libgcc1-${Va_LIBGCC}/libgcc-dev
	tar cjf "${WORK_DIR}/libgcc1-frc${V_YEAR}-armel-cross_${Va_LIBGCC}.orig.tar.bz2" * --owner=0 --group=0
popd
pushd "${REPACK_DIR}"/libstdc++6/
	mkdir libstdc++6-${Va_LIBSTDCPP}
	mv out libstdc++6-${Va_LIBSTDCPP}/libstdc++6
	mv ../libstdc++6-dev/out libstdc++6-${Va_LIBSTDCPP}/libstdc++6-dev
	tar cjf "${WORK_DIR}/libstdc++6-frc${V_YEAR}-armel-cross_${Va_LIBSTDCPP}.orig.tar.bz2" * --owner=0 --group=0
popd

# Make frcmake tarball
cd "${REPACK_DIR}"
rm -rf frcmake${V_YEAR}-${V_FRCMAKE}
mkdir frcmake${V_YEAR}-${V_FRCMAKE}
pushd frcmake${V_YEAR}-${V_FRCMAKE}
sed -e "s/frc/frc${V_YEAR}/g" "${SCRIPT_DIR}"/tools/frcmake > frcmake${V_YEAR}
chmod a+x frcmake${V_YEAR}
sed -e "s/frc/frc${V_YEAR}/g" "${SCRIPT_DIR}"/tools/frc-cmake-toolchain > frc${V_YEAR}-cmake-toolchain
chmod a+x frc${V_YEAR}-cmake-toolchain
sed -e "s/frc/frc${V_YEAR}/g" "${SCRIPT_DIR}"/tools/toolchain.cmake > toolchain.cmake
sed -e "s/frc/frc${V_YEAR}/g" -e "s/frc${V_YEAR}make/frcmake${V_YEAR}/g" "$SCRIPT_DIR"/tools/frcmake-nix-makefile > Makefile
popd
tar cjf "${REPACK_DIR}"/frcmake${V_YEAR}-${V_FRCMAKE}.tar.bz2 frcmake${V_YEAR}-${V_FRCMAKE}
