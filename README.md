# W.P.I. Toolchains

## Vocabulary
 * Host: The system in which code is compiled on
 * Target: The system in which the compiled code runs on 

## Supported Hosts
 * x86_64 Linux
   * Most systems during/after 2014 with glibc 2.19 or newer
 * x86_64 MacOS
   * Any system running MacOS 10.15 or newer
   * M1 should work through Rosetta (native support planned)
 * i686 Windows
   * Any system running Windows 7 or newer
   * Older systems may potentially work but are not supported
   * x86_64 should work through compatability

## Supported Targets

### N.I. Roborio
 * armel-roborio

### Ubuntu
 * arm64-xenial
 * arm64-bionic
 * arm64-focal

### Debian
 * armhf-buster (armv6)
   * Raspberry Pi OS 32-bit compatible
 * arm64-buster
   * Raspberry Pi OS 64-bit compatible
