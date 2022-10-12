from .enums.arch import Arch
from .enums.distro import Distro
from .enums.release import Release
from .consts import REPOS

def get_repo_url(distro: Distro, arch: Arch):
    repo = REPOS[distro]
    if type(repo) is str:
        return repo
    assert len(repo) == 2
    if arch is Arch.AMD64:
        return repo["archive"]
    else:
        return repo["port"]

def get_repo_packages_url(distro: Distro, arch: Arch, release: Release):
    repo = get_repo_url(distro, arch)
    if distro is Distro.ROBORIO or distro is Distro.ROBORIO_ACADEMIC:
        return "{}/Packages.gz".format(repo)
    return "{}/dists/{}/main/binary-{}/Packages.gz".format(repo, release, arch)
