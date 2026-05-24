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

def get_repo_url_adv(distro: Distro, arch: Arch, release: Release):
    repo = get_repo_url(distro, arch)
    if distro == Distro.SYSTEMCORE:
        return "{}/limelightosr-alpha-10-{}".format(repo, release)
    return "{}/dists/{}/main/binary-{}".format(repo, release, arch)

def get_repo_packages_url(distro: Distro, arch: Arch, release: Release):
    if distro == Distro.SYSTEMCORE:
        return None
    return "{}/Packages.gz".format(get_repo_url_adv(distro, arch, release))
