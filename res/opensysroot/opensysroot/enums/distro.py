from enum import Enum


class Distro(Enum):
    DEBIAN = "debian"
    SYSTEMCORE = "systemcore"

    def __str__(self):
        return self.value
