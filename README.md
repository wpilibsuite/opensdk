# W.P.I. Toolchains

## Vocabulary
 * Host: The system in which code is compiled on
 * Target: The system in which the compiled code runs on 

## Supported Hosts
 * x86_64 Linux
   * Most systems during/after 2014 with glibc 2.19 or newer
 * x86_64 MacOS
   * Any system running macOS/OSX 10.10 or newer
   * M1 should work through Rosetta
 * x86_64 Windows
   * Any system running Windows 7 or newer
   * Older systems may potentially work but are not supported
 * i686 Windows
   * Any system running Windows 7 or newer
   * Older systems may potentially work but are not supported
   * x86_64 should work through compatability

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
