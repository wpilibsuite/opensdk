from .enums.distro import Distro

REPOS = {
    Distro.DEBIAN: "http://ftp.debian.org/debian/",
    Distro.RASPBIAN: "http://archive.raspbian.org/raspbian",
    Distro.ROBORIO_STD: "https://download.ni.com/ni-linux-rt/feeds",
    Distro.ROBORIO_ACADEMIC: "https://download.ni.com/ni-linux-rt/feeds/academic",
    Distro.UBUNTU: {"port": "http://ports.ubuntu.com/ubuntu-ports",
                    "archive": "http://archive.ubuntu.com/ubuntu"}
}
