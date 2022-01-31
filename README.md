# Robotics Toolchains

## Supported Languages
  * C
  * C++
  * Fortran (roboRIO only)

## Supported Hosts

### Tier 1

| OS | Arch | Minimum Supported Release | Note |
| - | - | - | - |
| Windows | x86_64 | Windows XP | - |
| Linux | i686 | Ubuntu 18.04 | Only for Raspberry Pi OS targets |
| Linux | x86_64 | Ubuntu 18.04 | - |
| Mac | x86_64 | macOS 10.9 | - |

### Tier 2

NOTE: Tier 2 is not supported, but pull requests are accepted.

| OS | Arch | Minimum Supported Release |
| - | - | - |
| Windows | i686 | Windows XP |
| Linux | armv7 | Ubuntu 18.04 |
| Linux | arm64 | Ubuntu 18.04 |
| Linux | i686 | Ubuntu 18.04 |
| Mac | arm64 | macOS 11.0 |
| Mac | Universal | - |

## Supported Targets

| Architecture | Operating System | Version |
| - | - | - |
| ARMv7 (softfp) | N.I. Linux (roboRIO) Sumo | GCC 7.3
| ARMv7 (softfp) | N.I. Linux (roboRIO) Hardknott | GCC 10.2
| ARMv6 | Raspberry Pi OS 10 | GCC 8.3
| ARMv6 | Raspberry Pi OS 11 | GCC 10.2
| ARMv7 | Debian/Raspberry Pi OS 10 | GCC 8.3
| ARMv7 | Debian/Raspberry Pi OS 11 | GCC 10.2
| ARMv7 | Ubuntu 18.04 | GCC 7.3
| ARMv7 | Ubuntu 20.04 | GCC 9.3
| ARMv8 (64bit) | Debian/Raspberry Pi OS 10 | GCC 8.3
| ARMv8 (64bit) | Debian/Raspberry Pi OS 11 | GCC 10.2
| ARMv8 (64bit) | Ubuntu 18.04 | GCC 7.3
| ARMv8 (64bit) | Ubuntu 20.04 | GCC 9.3
| x86_64 | Debian 10 | GCC 8.3
| x86_64 | Debian 11 | GCC 10.2
| x86_64 | Ubuntu 18.04 | GCC 7.3
| x86_64 | Ubuntu 20.04 | GCC 9.3

* Note: Debian toolchains should work with Raspberry Pi OS when ran on a Pi 2 or newer 
-----

## Resources
  * [Linaro GCC toolchains](https://releases.linaro.org/components/toolchain/binaries/)
    * Good examples of (generic) ARM toolchains
  * [GCC Build instructions and configs](https://gcc.gnu.org/install/)

## Credits
  * (majenko) [Using lipo to combine toolchains](https://majenko.co.uk/blog/how-i-cross-compile-fat-binary-cross-compiler-os-x-big-sur)
  * (crosstool-ng) [GCC patches for M1 hosting](https://github.com/crosstool-ng/crosstool-ng/)
    * Copyright is owned by original authors of the patches and the Free Software Foundation where applicable
