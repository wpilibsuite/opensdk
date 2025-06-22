from enum import Enum


class Release(Enum):
    # Debian/Raspbian
    BUSTER = "buster"
    BULLSEYE = "bullseye"
    BOOKWORK = "bookworm"
    SID = "sid"

    # Ubuntu
    BIONIC = "bionic"
    FOCAL = "focal"
    JAMMY = "jammy"

    # NI Real-Time Linux
    NI2021 = "2021.8"
    NI2023 = "2023"

    # SystemCore
    RELEASE_155 = "155"

    def __str__(self):
        return self.value
