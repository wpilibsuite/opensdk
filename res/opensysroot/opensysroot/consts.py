from .enums.distro import Distro

REPOS = {
    Distro.DEBIAN: "http://ftp.debian.org/debian/",
    Distro.RASPBIAN: "http://archive.raspbian.org/raspbian",
    Distro.ROBORIO: "https://download.ni.com/ni-linux-rt/feeds/2021.5/arm/main/cortexa9-vfpv3",
    Distro.UBUNTU: {"port": "http://ports.ubuntu.com/ubuntu-ports",
                    "archive": "http://archive.ubuntu.com/ubuntu"}
}
