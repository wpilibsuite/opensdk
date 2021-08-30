Patches are pulled from debian upstream with changes to search the following
 * `/lib`
 * `/usr/lib`
Instead of just the `/lib`

To see how the changes are made compare `binutils-2.34.patch` with this
[link to debian upstream of 2.34](https://salsa.debian.org/toolchain-team/binutils/-/blob/binutils-2.34/debian/patches/129_multiarch_libpath.patch)
