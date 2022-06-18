from enum import Enum


class Arch(Enum):
    ARMHF = "armhf"
    ARM64 = "arm64"
    AMD64 = "amd64"
    CORTEXA9 = "cortexa9_vfpv3"

    def __str__(self):
        return self.value
