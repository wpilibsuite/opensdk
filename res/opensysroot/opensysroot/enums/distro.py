from enum import Enum


class Distro(Enum):
    DEBIAN = "debian"
    RASPBIAN = "raspbian"
    UBUNTU = "ubuntu"
    ROBORIO = "roborio"
    ROBORIO_ACADEMIC = "roborio-academic"

    def __str__(self):
        return self.value
