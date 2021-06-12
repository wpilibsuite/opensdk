from hashlib import sha1

from . import utils

import os
import requests


class AptPackage:
    def __init__(self, data):
        self.name = data["Package"]
        self.ver = utils.cleanup_version(data["Version"])
        if "SHA1" in data:
            self.sha1 = data["SHA1"]
        else:
            self.sha1 = None
        self.url = data["Repo"] + data["Filename"]

    def download(self, dir_path, dry=False, log=False):
        if not os.path.isdir(dir_path) and not dry:
            raise OSError("Download path does not exist %s" % dir_path)
        file_name = self.url.split("/")[-1]
        file_path = os.path.join(dir_path, file_name)

        r = requests.get(self.url)
        if log:
            print(r.status_code, file_name)
        if r.status_code != 200:
            raise OSError("Unable to download %s" % file_name)

        if self.sha1 is not None:
            if self.sha1 != sha1(r.content).hexdigest():
                raise OSError(
                    "SHA-1 mismatch for %s" % file_name)

        if dry or os.path.isfile(file_path):
            return
        with open(file_path, "wb") as out:
            out.write(r.content)


class AptPackageWithDeps(AptPackage):
    def __init__(self, data, deps):
        super().__init__(data)
        self.deps = [None] * len(deps)
        for i in range(len(deps)):
            self.deps[i] = AptPackage(deps[i])

    def download(self, dir_path, dry=False, log=False):
        super().download(dir_path, dry=dry, log=log)
        for dep in self.deps:
            dep.download(dir_path, dry=dry, log=log)
