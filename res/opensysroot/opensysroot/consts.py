from .enums.distro import Distro

REPOS = {
    Distro.DEBIAN: """
deb http://ftp.debian.org/debian bookworm main
deb http://ftp.debian.org/debian bullseye main
""",
    Distro.RASPBIAN: """
deb http://archive.raspbian.org/raspbian bookworm main
deb http://archive.raspbian.org/raspbian bullseye main
""",
    Distro.UBUNTU: """
deb http://archive.ubuntu.com/ubuntu lunar main
deb http://archive.ubuntu.com/ubuntu kinetic main
deb http://archive.ubuntu.com/ubuntu jammy main
deb http://archive.ubuntu.com/ubuntu focal main

deb http://ports.ubuntu.com/ubuntu-ports lunar main
deb http://ports.ubuntu.com/ubuntu-ports kinetic main
deb http://ports.ubuntu.com/ubuntu-ports jammy main
deb http://ports.ubuntu.com/ubuntu-ports focal main
""",
    Distro.ROBORIO_STD: """
ipk https://download.ni.com/ni-linux-rt/feeds 2022Q4 arm/main/all
ipk https://download.ni.com/ni-linux-rt/feeds 2022Q4 arm/main/cortexa9-vfpv3
ipk https://download.ni.com/ni-linux-rt/feeds 2022Q4 ni-main
ipk https://download.ni.com/ni-linux-rt/feeds 2022Q4 ni-lv2022
""",
    Distro.ROBORIO_ACADEMIC: """
ipk https://download.ni.com/ni-linux-rt/feeds/academic 2023 arm/main/all
ipk https://download.ni.com/ni-linux-rt/feeds/academic 2023 arm/main/cortexa9-vfpv3
ipk https://download.ni.com/ni-linux-rt/feeds 2022Q4 ni-main
ipk https://download.ni.com/ni-linux-rt/feeds 2022Q4 ni-lv2022
""",
}

BLOCKLIST = [
    # These packages cause issues for the roboRIO since they are packaged incorrectly
    # and have dependencies that do not exist.
    "dkms",

    # These packages cause issues for Raspberry Pi OS. Not exactly sure why, but these
    # are not needed for a sysroot.
    "perl",
    "perlapi",
    "debconf",

    # These packages are loaded at runtime, and are not necessary for cross-compiling
    "bash",
    "libdrm-nouveau2",
    "libdrm-amdgpu1",
    "libdrm-radeon1",
    "libdrm-tegra0",
    "libdrn-exynos1",
]
