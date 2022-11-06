"""
The Packages lists for APG and OPKG are quite similar
so the implementation is left as being distro agnostic
as only Debian/Ubuntu and the NI RoboRio is targeted.
"""
import io
import re
import gzip
import sqlite3
import sys
import requests
from pathlib import Path
from typing import Optional
from .. import consts

PACKAGE_VERSION_REGEX = re.compile(r'(\S+) \((\S+) (\S+)\)')

YAML_PKG_ARCH = re.compile(r"(^Architecture: )(.*)")
YAML_PKG_NAME = re.compile(r"(^Package: )(.*)")
YAML_PKG_PATH = re.compile(r"(^Filename: )(.*)")
YAML_PKG_PROVIDE = re.compile(r"(^Provides: )(.*)")
YAML_PKG_DEP = re.compile(r"(^Depends: )(.*)")
YAML_PKG_VER = re.compile(r"(^Version: )(.*)")
YAML_PKG_LICENSE = re.compile(r"(^License: )(.*)")
YAML_PKG_SECTION = re.compile(r"(^License: )(.*)")

_DB_INIT = """
CREATE TABLE Packages(ID INTEGER PRIMARY KEY AUTOINCREMENT,
    Name, Architecture, Version, Filename, Dependencies, BaseURL);
CREATE TABLE PackageInfo(ID INTEGER PRIMARY KEY AUTOINCREMENT,
    Name, License, Section);
"""
_DB_INSERT = """
INSERT INTO Packages
    (Name, Architecture, Version, Filename, Dependencies, BaseURL)
    VALUES (?,?,?,?,?,?)
"""
_DB_INSERT_EXTRA = """
INSERT INTO PackageInfo
    (Name, License, Section)
    VALUES (?,?,?)
"""
_DB_FIND_FILENAME = """
SELECT Filename, Dependencies, BaseURL FROM Packages WHERE 
    (Name LIKE '%%{0}%%') AND
    (Architecture LIKE '%%{1}%%' OR Architecture == 'all')
"""


def _parse_lists(base: str, packages: str, cursor: sqlite3.Cursor):
    """
    Parse the package lists from the Distro database.

    :param packages: The package lists to parse.
    :return: A list of packages.
    """
    if not isinstance(packages, str):
        raise TypeError("Expected string, got {}".format(type(packages)))
    if not isinstance(cursor, sqlite3.Cursor):
        raise TypeError("cursor must be a sqlite3.Cursor")
    packages: list[str] = packages.split("\n\n")
    for package in packages:
        # StringIO is used to iterate per line as if it were a file.
        data = io.StringIO(package)
        line = data.readline().strip()
        arch: str = None
        name: str = None
        vers: str = None
        path: str = None
        deps: Optional[str] = None
        license: Optional[str] = None
        section: Optional[str] = None
        while line:
            if len(line) == 0 or line[0] == ' ':
                continue
            _arch = YAML_PKG_ARCH.match(line)
            _pkg = YAML_PKG_NAME.match(line)
            _pwd = YAML_PKG_PATH.match(line)
            _ver = YAML_PKG_VER.match(line)
            _provide = YAML_PKG_PROVIDE.match(line)
            _dep = YAML_PKG_DEP.match(line)
            _license = YAML_PKG_LICENSE.match(line)
            _section = YAML_PKG_SECTION.match(line)
            if _arch:
                arch = _arch.group(2).strip()
            elif _pkg:
                name = _pkg.group(2).strip()
            elif _pwd:
                path = _pwd.group(2).strip()
            elif _ver:
                vers = _ver.group(2).strip()
            elif _dep:
                deps = _dep.group(2).strip()
            elif _license:
                license = _license.group(2).strip()
            elif _section:
                section = _section.group(2).strip()
            line = data.readline().strip()
        if name is None or vers is None or path is None:
            continue
        cursor.execute(_DB_INSERT, (name, arch, vers,
                       path, deps, base))
        cursor.execute(_DB_INSERT_EXTRA, (name, license, section))


class Database:
    con: sqlite3.Connection
    cur: sqlite3.Cursor
    PACKAGES_TO_INSTALL: dict
    DEPENDENCIES_TO_RESOLVE: list

    def __init__(self, arch, package_urls, db: str = ":memory:") -> None:
        self.PACKAGES_TO_INSTALL = dict()
        self.DEPENDENCIES_TO_RESOLVE = list()
        self.arch = arch
        self.con = sqlite3.connect(db)
        self.cur = self.con.cursor()
        self.cur.executescript(_DB_INIT)
        for (base, pkg_file) in package_urls:
            data = requests.get(pkg_file)
            if data.status_code != 200:
                raise IOError(
                    "Could not download package lists from {}".format(pkg_file))
            data = gzip.decompress(data.content)
            _parse_lists(base, data.strip().decode('utf8'), self.cur)
            self.con.commit()

    def __del__(self) -> None:
        self.con.commit()
        self.con.close()

    def add_dependency(self, data: str):
        data = data.split(',')
        for dependency in data:
            if '|' in dependency:
                self.DEPENDENCIES_TO_RESOLVE.append(dependency)
            else:
                self.add_package_approx(dependency)

    def add_package_approx(self, data: str):
        data = data.strip()
        version = PACKAGE_VERSION_REGEX.findall(data)

        if version:
            # In case there is a version
            package_name = version[0][0]
            version_type = version[0][1]
            version = version[0][2]
            self.add_package(package_name, version, version_type)
        else:
            # In case there is no version
            self.add_package(data)

    def add_package(self, name: str, version=None, version_type=None):
        # These packages cause issues for the roboRIO since they are packaged incorrectly
        # and have dependencies that do not exist
        name = name.replace(':any', '')
        if name in consts.BLOCKLIST:
            return
        if name in self.PACKAGES_TO_INSTALL:
            return
        self.cur.execute(_DB_FIND_FILENAME.format(name, self.arch))
        info = self.cur.fetchone()
        if not info:
            raise RuntimeError("Cannot find exact package {}".format(name))
        self.PACKAGES_TO_INSTALL[name] = {
            "name": name, "filename": info[0], "base_url": info[2]}

        if version:
            self.PACKAGES_TO_INSTALL[name]['version'] = version
            self.PACKAGES_TO_INSTALL[name]['version_type'] = version_type
        dependencies = info[1]
        if dependencies:
            self.add_dependency(dependencies)

    def post_resolve(self):
        for dependency in self.DEPENDENCIES_TO_RESOLVE:
            if '|' not in dependency:
                raise RuntimeError("An Unexpected dependency found")
            unresolved_dependencies = dependency.split('|')
            for unresolved_dependency in unresolved_dependencies:
                try:
                    self.add_package_approx(unresolved_dependency)
                    return
                except:
                    pass
            raise RuntimeError(
                "Cannot find dependency '{}'".format(dependency))
        self.DEPENDENCIES_TO_RESOLVE.clear()

    def download(self, downloads: Path):
        assert downloads.is_dir()
        for pkg in self.PACKAGES_TO_INSTALL.values():
            pkg_file = pkg["filename"].split("/")[-1]
            pkg_file = Path(downloads, pkg_file)
            if pkg_file.exists():
                print("Using cached {}".format(pkg_file.name))
                continue
            print("Downloading {}".format(pkg_file.name))
            pkg_url = "{}/{}".format(pkg["base_url"], pkg['filename'])
            pkg_data = requests.get(pkg_url)
            if pkg_data.status_code != 200:
                print(pkg_url, file=sys.stderr)
                raise ConnectionError("Could not download {} due to status code {}".format(
                    pkg_file.name,
                    pkg_data.status_code))
            with pkg_file.open("wb") as fd:
                fd.write(pkg_data.content)
