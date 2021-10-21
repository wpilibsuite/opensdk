Patches in the `linaro` subdirectory is fairly complex. It is needed to get
proper ABI with arm64 codegen on debian systems. Versions 9.x and up do not
apply any patches.

Patches were pulled from https://salsa.debian.org/toolchain-team/gcc/ by
checking out the gcc version release and going to `debian/patches`. From there,
two files were copied, `gcc-linaro.diff` and `gcc-linaro-docs.diff`. They were
renamed to `gcc-{ver}.patch` and `gcc-{ver}-docs.patch` respectivly. Internally,
the folder structure was changed to replace `a/src/` to `a` and `b/src` to `b`.
