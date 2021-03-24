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
