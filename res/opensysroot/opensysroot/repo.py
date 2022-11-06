from .enums.arch import Arch
from .enums.distro import Distro
from .enums.release import Release
from .consts import REPOS
import re

url_parser = re.compile(r"(ipk|deb) (\S+) (\S+) (\S+)")


def _get_repo_urls(distro):
    lists_raw = REPOS[distro]
    lists_raw = lists_raw.splitlines()
    return [repo for repo in lists_raw if len(repo) > 0]


def _get_repo_url_full(groups, arch):
    if groups[0] == 'deb':
        return "{}/dists/{}/{}/binary-{}".format(groups[1], groups[2], groups[3], str(arch))
    if groups[0] == 'ipk':
        return "{}/{}/{}".format(groups[1], groups[2], groups[3])
    return ""


def get_repo_urls(distro: Distro, arch: Arch, release: Release):
    # Get all repositories for the current distro
    str_lists = _get_repo_urls(distro)

    # Only read the urls of the current release. Skip if this is the roborio academic
    # branch, since it is pulling from two different releases.
    if distro != Distro.ROBORIO_ACADEMIC:
        str_lists = [repo for repo in str_lists if (str(release) in repo)]

    # Canonical stores ARM packages in a repository that is different from the x86 builds.
    if distro == Distro.UBUNTU:
        if arch == Arch.AMD64:
            str_lists = [repo for repo in str_lists if ("archive" in repo)]
        else:
            str_lists = [repo for repo in str_lists if ("port" in repo)]

    # Parse the strings so we can get metadata from the regex groups
    lists = [url_parser.match(repo).groups() for repo in str_lists]

    retval = []
    for groups in lists:
        full = _get_repo_url_full(groups, arch)
        if distro in (Distro.ROBORIO_STD, Distro.ROBORIO_ACADEMIC):
            retval.append((full, full + "/Packages.gz"))
        else:
            retval.append((groups[1], full + "/Packages.gz"))
    return retval
