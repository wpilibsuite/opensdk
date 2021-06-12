DISTRO_REPOS = {
    "raspi": {
        "pkgs": "dists/{release}/{channel}/binary-{arch}/Packages.gz",
        "repos": [
            "http://raspbian.mirrors.lucidnetworks.net/raspbian/",
        ]
    },
    "debian": {
        "pkgs": "dists/{release}/{channel}/binary-{arch}/Packages.gz",
        "repos": [
            "http://mirrors.kernel.org/debian/",
        ]
    },
    "ubuntu": {
        "pkgs": "dists/{release}/{channel}/binary-{arch}/Packages.gz",
        "repos": [
            "http://mirrors.kernel.org/ubuntu/",
            "http://ports.ubuntu.com/ubuntu-ports/"
        ]
    },
    "ni": {
        "pkgs": "Packages.gz",
        "repos": [
            "http://download.ni.com/ni-linux-rt/feeds/2019/arm/cortexa9-vfpv3/",
        ]
    }
}

DISTRO_REPO_CHANNELS = {
    "raspi": ["main", "contrib"],
    "debian": ["main", "contrib"],
    "ubuntu": ["main", "multiverse", "universe"],
    "ni": []
}

DISTRO_ARCHS = {
    "raspi": ["armhf"],
    "debian": ["armhf", "arm64", "amd64"],
    "ubuntu": ["armhf", "arm64", "amd64"],
    "ni": ["cortexa9-vfpv3"]
}

DISTRO_RELEASES = {
    "raspi": ["buster", "bullseye"],
    "debian": ["buster", "bullseye"],
    "ubuntu": ["bionic", "focal"],
    "ni": []
}

DISTRO_RELEASE_CHANNELS = {
    "raspi": [""],
    "debian": ["", "-updates"],
    "ubuntu": ["", "-updates", "-security"],
    "ni": [] 
}
