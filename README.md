# OpenSDK

## Supported Languages
  * C
  * C++
  * Fortran (roboRIO only)
    * To power the [RobotPy](https://github.com/robotpy) project

## Supported Hosts

All tiers should compile with these scripts. But support will only
be given if the OS vendor supports the platform.

For example, these tools should work on Windows XP but support
will only be given to Windows 10 or newer. The same logic applies
for macOS and Ubuntu.

### Tier 1

| OS      | Arch   | Known to work on |
| ------- | ------ | ---------------- |
| Windows | x86_64 | Windows XP       |
| Linux   | x86_64 | Ubuntu 20.04     |
| Mac     | x86_64 | macOS 10.9       |
| Mac     | ARMv8  | macOS 11.0       |

### Tier 2

Tier 2 is used for select targets on an as needed basis.

| OS    | Arch  | Known to work on          | Note                     |
| ----- | ----- | ------------------------- | ------------------------ |
| Linux | ARMv7 | Debian/Raspberry Pi OS 12 | Only for roboRIO targets |
| Linux | ARMv8 | Debian/Raspberry Pi OS 12 | Only for roboRIO targets |

### Tier 3

Tier 3 is not built in CI nor is tested, but bugs or merge requests will be addressed.

| OS      | Arch  | Known to work on |
| ------- | ----- | ---------------- |
| Windows | i686  | Windows XP       |
| Linux   | i686  | Ubuntu 20.04     |
| Linux   | ARMv7 | Ubuntu 20.04     |
| Linux   | ARMv8 | Ubuntu 20.04     |

## Supported Targets

| Architecture   | Operating System              | Version  | Release Download Name                    |
| -------------- | ----------------------------- | -------- | ---------------------------------------- |
| ARMv7 (softfp) | N.I. Linux (roboRIO) Academic | GCC 12.1 | `cortexa9_vfpv3-roborio-academic-2025-*` |
| ARMv6          | Raspberry Pi OS 12            | GCC 12.2 | `armhf-raspi-bookworm-2025-*`            |
| ARMv7          | Debian/Raspberry Pi OS 12     | GCC 12.2 | `armhf-bookworm-2025-*`                  |
| ARMv8          | Debian/Raspberry Pi OS 12     | GCC 12.2 | `arm64-bookworm-2025-*`                  |

-----

## Resources
  * [Linaro GCC toolchains](https://releases.linaro.org/components/toolchain/binaries/)
    * Good examples of (generic) ARM toolchains
  * [GCC Build instructions and configs](https://gcc.gnu.org/install/)

## Credits
  * (crosstool-ng) [GCC patches for M1 hosting](https://github.com/crosstool-ng/crosstool-ng/)

## Licensing Notice

**NOTE:** Refer to the text in `COPYING` for the full legal statement. The text written
below is made from a very basic understanding of GPLv3 (and its exceptions).

As per GPLv3 (snippet below) all scripts to build the GNU toolchain must be provided
under the same license. So, the scripts in the repository are released under GPLv3.

> For an executable work, complete source code means [...], plus the
> scripts used to control compilation and installation of the executable.

The GCC exception still applies so the toolchain built with these scripts can still
be used for any project as per the exception. A copy of this exception can be found
[here](https://github.com/gcc-mirror/gcc/blob/master/COPYING.RUNTIME).

The files under `patches/` are released under the same license as the project in which
it targets. As of April 2022, all projects are currently GPLv3 so the patches are also
released under GPLv3. 
