from copy import copy
from packaging import version
import gzip
import requests
import yaml

from .package import *
from .consts import *
from . import utils


class AptRepo:
    _KEYWORDS = ["Package", "Architecture",
                 "Version", "Depends", "Filename", "SHA1"]

    def __init__(self, distro, release, arch):
        utils.verify_config(distro, release, arch)
        self.distro = distro
        self.release = release
        self.arch = arch
        self.packages = []
        if distro != "ni":
            repos = DISTRO_REPOS[distro]["repos"]
            rel_channels = DISTRO_RELEASE_CHANNELS[distro]
            channels = DISTRO_REPO_CHANNELS[distro]
            for repo in repos:
                for channel in channels:
                    for rel_channel in rel_channels:
                        suburl = DISTRO_REPOS[distro]["pkgs"].format(
                            release=release + rel_channel, channel=channel, arch=arch)
                        self._read_repo(repo, suburl)
        else:
            self._read_repo(
                DISTRO_REPOS[distro]["repos"][0], DISTRO_REPOS[distro]["pkgs"])

    def _deserialize_pkg(self, data):
        if len(data) == 0:
            return None
        out = []
        for line in data.strip().split("\n"):
            if not any(line.startswith(keyword) for keyword in self._KEYWORDS):
                continue
            out.append(line)
        retval = yaml.safe_load("\n".join(out))
        del out
        assert all(key in self._KEYWORDS for key in retval.keys())
        retval["Version"] = utils.cleanup_version(retval["Version"])
        return retval

    def _read_repo(self, repo, packages_path):
        data = requests.get(repo + packages_path)
        if utils.expected_content_type(data.headers, "application/x-gzip"):
            return
        if data.status_code != 200:
            return
        decompressed_file = gzip.decompress(data.content)
        for pkg in decompressed_file.decode("UTF-8").split("\n\n"):
            out_pkg = self._deserialize_pkg(pkg)
            if out_pkg is None:
                continue
            out_pkg["Repo"] = repo
            self.packages.append(out_pkg)
        del decompressed_file

    def find_packages_by_name(self, name):
        _name = name.split(":")[0]
        canidates = filter(lambda pkg: _name == pkg["Package"], self.packages)
        return list(canidates)

    def find_latest_package_by_name(self, name):
        canidates = self.find_packages_by_name(name)
        if len(canidates) == 0:
            raise ValueError("Could not find {}".format(name))
        newest = canidates[0]
        for canidate in canidates:
            canidate_ver = version.parse(str(canidate["Version"]))
            newest_ver = version.parse(str(newest["Version"]))
            if canidate_ver > newest_ver:
                newest = canidate
        return copy(newest)

    def _find_pkg_uniq(self, pkg_list, main_pkg):
        uniq = []
        for pkg in pkg_list:
            def call(_pkg):
                nonlocal pkg
                return _pkg["Package"] == pkg["Package"]
            if len(uniq) != 0 and any(filter(call, uniq)):
                continue
            if pkg["Package"] is main_pkg:
                continue
            uniq.append(pkg)
        return uniq

    def _find_pkg_conv(self, pkg_list):
        retval = [None] * len(pkg_list)
        for i in range(len(pkg_list)):
            retval[i] = AptPackage(pkg_list[i])
        return retval

    def _find_pkg_flatten(self, pkg):
        _pkg = copy(pkg)
        if "Depends" in _pkg:
            deps = _pkg.pop("Depends")
        pkg_list = [_pkg]
        for dep in deps:
            if dep is not None and "Depends" in dep.keys():
                pkg_list += self._find_pkg_flatten(dep)
        return pkg_list

    def find_pkg(self, name, upper_depend=None, first=True):
        package = self.find_latest_package_by_name(name)
        if "Depends" not in package:
            if first:
                return AptPackageWithDeps(package, [])
            else:
                return package
        assert type(package["Depends"]) == str
        depends = package["Depends"].split(",")
        for i in range(len(depends)):
            dependency = depends[i].strip().split(" ")[0]
            if upper_depend == dependency:
                depends[i] = None
                continue
            depends[i] = self.find_pkg(
                dependency, upper_depend=name, first=False)
        package["Depends"] = depends
        if first:
            _deps = self._find_pkg_flatten(package)
            _deps = self._find_pkg_uniq(_deps, package["Package"])
            return AptPackageWithDeps(package, _deps)
        else:
            return package
