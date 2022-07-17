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

    # Misc
    ROBORIO = "roborio"

    def __str__(self):
        return self.value
