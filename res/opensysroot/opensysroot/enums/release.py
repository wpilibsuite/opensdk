from enum import Enum


class Release(Enum):
    # Debian
    TRIXIE = "trixie"

    # SystemCore
    RELEASE_308 = "308"

    def __str__(self):
        return self.value
