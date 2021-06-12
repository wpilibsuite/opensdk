from . import consts
import re


def verify_config(distro, release, arch):
    if not distro in consts.DISTRO_REPOS:
        raise ValueError("Distro {} is not supported".format(distro))
    if not arch in consts.DISTRO_ARCHS[distro]:
        raise ValueError("Architecture {} is not supported on {}".format(arch, distro))
    if not release in consts.DISTRO_RELEASES[distro] and distro != "ni":
        raise ValueError("Release {} is not avaliable on {}".format(release, distro))
    return


def expected_content_type(headers, expected):
    return "Content-Type" in headers and headers["Content-Type"] is expected


def cleanup_version(ver):
    if type(ver) is not str:
        return str(float(ver))
    _ver = str(ver)
    if ":" in _ver:
        _ver = _ver.split(":")[1]
    _ver = re.findall("^[0-9.]*", _ver)[0]
    return _ver
