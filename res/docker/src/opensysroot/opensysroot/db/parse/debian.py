import re
from distutils.version import StrictVersion

# Pulling Debian package versioning syntax from
# https://readme.phys.ethz.ch/documentation/debian_version_numbers/


VER_SPLIT = re.compile(r"(?P<version>[\d\.]+)(?P<meta>\W[a-z]*.*)")

class DebianVersion:
    """
    Currently ununsed but is a reference for future projects
    """
    def __init__(self, version: str) -> None:
        if not isinstance(version, str):
            raise TypeError("Expected string, got {}".format(type(version)))
        match = VER_SPLIT.match(version)
        self._data = dict(match.groupdict())
        if match is None or len(self._data) != 2:
            raise ValueError("Invalid version string: {}".format(version))
        self._data['version'] = StrictVersion(self._data['version'])

    def __repr__(self) -> str:
        return "DebianVersion({}{})".format(self._data['version'], self._data['meta'])
    def __lt__(self, other):
        return self._data['version'] < other._data['version']
    def __le__(self, other):
        return self._data['version'] <= other._data['version']
    def __eq__(self, other):
        return self._data['version'] == other._data['version']
    def __ne__(self, other):
        return self._data['version'] != other._data['version']
    def __gt__(self, other):
        return self._data['version'] > other._data['version']
    def __ge__(self, other):
        return self._data['version'] >= other._data['version']

