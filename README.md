# W.P.I. Toolchains

## Vocabulary
 * Host: The system in which code is compiled on
 * Target: The system in which the compiled code runs on 

## Supported Hosts
 * x86_64 Linux
   * Most systems during/after 2014 with glibc 2.19 or newer
 * x86_64 macOS
   * All systems running macOS/OSX 10.10 or newer
 * i686/x86_64 Windows
   * All systems running Windows 7 or newer (older may work)
 * Using Compatability Layers
   * Use i686 Windows builds for Windows 10 on ARM
   * Use x86_64 Windows builds for Windows 10 on ARM (Insiders Channel)
   * Use x86_64 macOS builds for macOS on Apple Silicon

## Supported Targets

### N.I. RoboRIO
 * roborio
   * armel

### Ubuntu
 * Bionic (18.04)
   * armhf
   * arm64
 * Focal (20.04)
   * armhf
   * arm64

### Debian/Raspberry Pi OS
 * Buster
   * armhf (armv6z)
   * arm64
 * Bullseye (testing)
   * armhf (armv6z)
   * arm64

## Resources
 * [How to cross compile with LLVM based tools](https://archive.fosdem.org/2018/schedule/event/crosscompile/attachments/slides/2107/export/events/attachments/crosscompile/slides/2107/How_to_cross_compile_with_LLVM_based_tools.pdf)
   * Good content but we are not using much LLVM specific stuff.
 * [Linaro GCC toolchains](https://releases.linaro.org/components/toolchain/binaries/)
   * Good examples of (generic) ARM toolchains
 * [GCC Build instructions and configs](https://gcc.gnu.org/install/)