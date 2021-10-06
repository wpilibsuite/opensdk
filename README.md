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
| x86_64 | Linux | Ubuntu 16.04 |
| x86_64 | macOS | macOS 10.9 |
| x86_64 | Win64 | Windows 7 |
| i686 | Win32 | Windows 7 |

## Supported Targets

| Architecture | Operating System | Tuple |
| - | - | - |
| ARMv7 (softfp) | N.I. Linux (roboRIO) Stable | arm-frc2021-linux-gnueabi |
| ARMv7 (softfp) | N.I. Linux (roboRIO) Staging | arm-frc2021-linux-gnueabi |
| ARMv6z | Raspberry Pi OS 10 for Pi zero/one | arm-rpi0_buster-linux-gnueabihf |
| ARMv6z | Raspberry Pi OS 11 for Pi zero/one | arm-rpi0_bullseye-linux-gnueabihf |
| ARMv7 | Debian/Raspberry Pi OS 10 | arm-buster-linux-gnueabihf |
| ARMv7 | Debian/Raspberry Pi OS 11 | arm-bullseye-linux-gnueabihf |
| ARMv7 | Ubuntu 18.04 | arm-bionic-linux-gnueabihf |
| ARMv7 | Ubuntu 20.04 | arm-focal-linux-gnueabihf |
| ARMv8 (64bit) | Debian/Raspberry Pi OS 10 | aarch64-buster-linux-gnu |
| ARMv8 (64bit) | Debian/Raspberry Pi OS 11 | aarch64-bullseye-linux-gnu |
| ARMv8 (64bit) | Ubuntu 18.04 | aarch64-bionic-linux-gnu |
| ARMv8 (64bit) | Ubuntu 20.04 | aarch64-focal-linux-gnu |
-----

## Resources
 * [How to cross compile with LLVM based tools](https://archive.fosdem.org/2018/schedule/event/crosscompile/attachments/slides/2107/export/events/attachments/crosscompile/slides/2107/How_to_cross_compile_with_LLVM_based_tools.pdf)
   * Good content but we are not using much LLVM specific stuff.
 * [Linaro GCC toolchains](https://releases.linaro.org/components/toolchain/binaries/)
   * Good examples of (generic) ARM toolchains
 * [GCC Build instructions and configs](https://gcc.gnu.org/install/)
