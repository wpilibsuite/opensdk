from enum import Enum


class Release(Enum):
    # Debian
    TRIXIE = "trixie"

    # SystemCore
    RELEASE_150 = "150"

    def __str__(self):
        return self.value
