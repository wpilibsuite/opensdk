# Debian sysroot enablement

The Debian filesystem is different from the simple NI Linux layout. Debian chose
to use a design which allowed for the same development packages to be installed 
with differing architectures. This can make Debian-to-Debian development quite
easy but it requires further patching to work with a third-party toolchain.

## GCC
* https://salsa.debian.org/toolchain-team/gcc/-/blob/gcc-10-debian/debian/patches/gcc-multiarch.diff
* https://salsa.debian.org/toolchain-team/gcc/-/blob/gcc-10-debian/debian/patches/gcc-multilib-multiarch.diff
* https://salsa.debian.org/toolchain-team/gcc/-/blob/gcc-10-debian/debian/patches/g%2B%2B-multiarch-incdir.diff

## Binutils
* https://salsa.debian.org/toolchain-team/binutils/-/blob/binutils-2.38/debian/patches/129_multiarch_libpath.patch