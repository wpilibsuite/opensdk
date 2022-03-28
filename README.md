# Robotics Toolchains

## Supported Languages
  * C
  * C++
  * Fortran (roboRIO only)
    * To power the [RobotPy](https://github.com/robotpy) project

## Supported Hosts

### Tier 1

| OS | Arch | Minimum Supported Release |
| - | - | - |
| Windows | x86_64 | Windows XP |
| Linux | x86_64 | Ubuntu 18.04 |
| Mac | x86_64 | macOS 10.9 |

### Tier 2

Tier 2 is used for select targets on an as needed basis.

| OS | Arch | Minimum Supported Release | Note |
| - | - | - | - |
| Linux | i686 | Ubuntu 18.04 | Only for Raspberry Pi OS targets |

### Tier 3

Tier 3 is not built in CI nor is tested, but bug/merge requests will be addressed.

| OS | Arch | Minimum Supported Release |
| - | - | - |
| Windows | i686 | Windows XP |
| Linux | i686 | Ubuntu 18.04 |
| Linux | ARMv7 | Ubuntu 18.04 |
| Linux | ARMv8 | Ubuntu 18.04 |
| Mac | ARMv8 | macOS 11.0 |
| Mac | Universal | - |

## Supported Targets

| Architecture | Operating System | Version |
| - | - | - |
| ARMv7 (softfp) | N.I. Linux (roboRIO) Sumo | GCC 7.3
| ARMv7 (softfp) | N.I. Linux (roboRIO) Staging | GCC 11.2
| ARMv6 | Raspberry Pi OS 10 | GCC 8.3
| ARMv6 | Raspberry Pi OS 11 | GCC 10.2
| ARMv7 | Debian/Raspberry Pi OS 10 | GCC 8.3
| ARMv7 | Debian/Raspberry Pi OS 11 | GCC 10.2
| ARMv7 | Ubuntu 18.04 | GCC 7.3
| ARMv7 | Ubuntu 20.04 | GCC 9.3
| ARMv8 | Debian/Raspberry Pi OS 10 | GCC 8.3
| ARMv8 | Debian/Raspberry Pi OS 11 | GCC 10.2
| ARMv8 | Ubuntu 18.04 | GCC 7.3
| ARMv8 | Ubuntu 20.04 | GCC 9.3

-----

## Resources
  * [Linaro GCC toolchains](https://releases.linaro.org/components/toolchain/binaries/)
    * Good examples of (generic) ARM toolchains
  * [GCC Build instructions and configs](https://gcc.gnu.org/install/)

## Credits
  * (majenko) [Using lipo to combine toolchains](https://majenko.co.uk/blog/how-i-cross-compile-fat-binary-cross-compiler-os-x-big-sur)
  * (crosstool-ng) [GCC patches for M1 hosting](https://github.com/crosstool-ng/crosstool-ng/)
    * Copyright is owned by original authors of the patches and the Free Software Foundation where applicable
