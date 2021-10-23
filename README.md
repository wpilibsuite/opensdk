# Robotics Toolchains

## Supported Languages
  * C
  * C++
  * Fortran (roboRIO only)

## Supported Hosts

| Architecture | OS | Minimum Supported Release |
| - | - | - |
| ARMv7 | Linux | Ubuntu 16.04 |
| ARMv8 | Linux | Ubuntu 16.04 |
| i686 | Linux | Ubuntu 16.04 |
| x86_64 | Linux | Ubuntu 16.04 |
| i686 | Win32 | Windows 7 |
| x86_64 | Win64 | Windows 7 |
| ARMv8 | macOS | macOS 11.0 |
| x86_64 | macOS | macOS 10.9 |

## Supported Targets

| Architecture | Operating System | Tuple |
| - | - | - |
| ARMv7 (softfp) | N.I. Linux (roboRIO) Stable | arm-frc2022-linux-gnueabi |
| ARMv7 (softfp) | N.I. Linux (roboRIO) Staging | arm-frc2022-linux-gnueabi |
| ARMv6z | Raspberry Pi OS 10 | armv6z-buster-linux-gnueabihf |
| ARMv6z | Raspberry Pi OS 11 | armv6z-bullseye-linux-gnueabihf |
| ARMv7 | Debian/Raspberry Pi OS 10 | armv7-buster-linux-gnueabihf |
| ARMv7 | Debian/Raspberry Pi OS 11 | armv7-bullseye-linux-gnueabihf |
| ARMv7 | Ubuntu 18.04 | armv7-bionic-linux-gnueabihf |
| ARMv7 | Ubuntu 20.04 | armv7-focal-linux-gnueabihf |
| ARMv8 (64bit) | Debian/Raspberry Pi OS 10 | aarch64-buster-linux-gnu |
| ARMv8 (64bit) | Debian/Raspberry Pi OS 11 | aarch64-bullseye-linux-gnu |
| ARMv8 (64bit) | Ubuntu 18.04 | aarch64-bionic-linux-gnu |
| ARMv8 (64bit) | Ubuntu 20.04 | aarch64-focal-linux-gnu |
| x86_64 | Debian 10 | x86_64-buster-linux-gnu |
| x86_64 | Debian 11 | x86_64-bullseye-linux-gnu |
| x86_64 | Ubuntu 18.04 | x86_64-bionic-linux-gnu |
| x86_64 | Ubuntu 20.04 | x86_64-focal-linux-gnu |

* Note: Debian toolchains should work with Raspberry Pi OS when ran on a Pi 2 or newer 
-----

## Resources
 * [How to cross compile with LLVM based tools](https://archive.fosdem.org/2018/schedule/event/crosscompile/attachments/slides/2107/export/events/attachments/crosscompile/slides/2107/How_to_cross_compile_with_LLVM_based_tools.pdf)
   * Good content but we are not using much LLVM specific stuff.
 * [Linaro GCC toolchains](https://releases.linaro.org/components/toolchain/binaries/)
   * Good examples of (generic) ARM toolchains
 * [GCC Build instructions and configs](https://gcc.gnu.org/install/)
