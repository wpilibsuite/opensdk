from enum import Enum


class Release(Enum):
    # Debian/Raspbian
    BULLSEYE = "bullseye"
    BOOKWORK = "bookworm"

    # Ubuntu
    BIONIC = "bionic"
    FOCAL = "focal"
    JAMMY = "jammy"
    KINETIC = "kinetic"
    LUNAR = "lunar"

    # NI Real-Time Linux
    NI2022 = "2022Q4"
    NI2023 = "2023"

    def __str__(self):
        return self.value
