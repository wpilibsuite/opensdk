from enum import Enum


class Arch(Enum):
    ARM64 = "arm64"
    AMD64 = "amd64"

    def __str__(self):
        return self.value
