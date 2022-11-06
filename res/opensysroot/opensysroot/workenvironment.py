import os
import re
import shutil
import subprocess
from pathlib import Path
from typing import Optional
from .enums.arch import Arch
from .enums.distro import Distro
from .enums.release import Release

TO_DELETE = [
    "etc",
    "var",
    "bin",
    "sbin",
    "usr/bin",
    "usr/sbin",
    "usr/share",
    "usr/{tuple}/bin",
    "usr/lib/{tuple}/audit",
    "usr/lib/{tuple}/ldscripts",
    "usr/lib/{tuple}/perl",
    "usr/lib/{tuple}/perl-base",
    "usr/lib/{tuple}/pkgconfig",
    "usr/lib/bfd-plugins",
    "usr/lib/compat-ld",
    "usr/lib/gold-ld",
    "usr/libexec",
    "usr/src"
]

ROBORIO_TO_RENAME = [
    "usr/include/c++/{ver}",
    "usr/lib/gcc/{tuple}/{ver}",
]


class WorkEnvironment:
    base: Path
    sysroot: Path
    downloads: Path

    def __init__(self, distro: Distro, arch: Arch, release: Release, workdir: Path, print_dest_sysroot: bool):
        self.arch = arch
        self.distro = distro
        self.base = Path(workdir, str(distro), str(release), str(arch))
        self.sysroot = Path(self.base, "sysroot")
        self.downloads = Path(self.base, "downloads")

        if print_dest_sysroot:
            print(self.sysroot.resolve())
            exit(0)

        if self.sysroot.exists():
            shutil.rmtree(self.sysroot)

        self.sysroot.mkdir(parents=True, exist_ok=True)
        self.downloads.mkdir(parents=True, exist_ok=True)

    def extract(self):
        for file in self.downloads.iterdir():
            subprocess.call(["dpkg", "-x", str(file), str(self.sysroot)])

    def clean(self):
        self._symlink()
        self._delete()
        if self.distro is Distro.ROBORIO_STD:
            self._major_only()

    def _major_only(self):
        ver = self.get_gcc_ver()
        ver_major = ver.split(".")[0]
        tuple = self.get_orig_tuple()
        for dir in ROBORIO_TO_RENAME:
            oldname = dir.format(ver=ver, tuple=tuple)
            newname = dir.format(ver=ver_major, tuple=tuple)
            oldname = Path(self.sysroot, oldname)
            newname = Path(self.sysroot, newname)
            shutil.move(oldname, newname)

    def _delete(self):
        tuple = self.get_orig_tuple()
        for subpath in TO_DELETE:
            xdir = Path(self.sysroot, subpath.format(tuple=tuple))
            if xdir.exists():
                shutil.rmtree(xdir)

    def _symlink(self):
        for file in self.sysroot.glob("**/*"):
            if not file.is_symlink():
                continue
            if "usr/bin" in str(file):
                continue
            resolved = Path(os.readlink(file))
            if resolved.is_absolute():
                resolved = Path("{}/{}".format(self.sysroot, resolved))
            elif file.is_file():
                resolved = Path(
                    "{}/{}".format(file.parent.absolute(), resolved))
            resolved = resolved.resolve()
            file.unlink()
            if resolved.is_dir():
                shutil.copytree(resolved, file)
            elif resolved.exists():
                shutil.copy2(resolved, file)

    def get_orig_tuple(self):
        if self.distro in (Distro.ROBORIO_STD, Distro.ROBORIO_ACADEMIC):
            assert self.arch is Arch.CORTEXA9
            return "arm-nilrt-linux-gnueabi"
        else:
            if self.arch is Arch.ARMHF:
                return "arm-linux-gnueabihf"
            if self.arch is Arch.ARM64:
                return "aarch64-linux-gnu"
            if self.arch is Arch.AMD64:
                return "x86_64-linux-gnu"
            raise RuntimeError("Unknown System")

    def get_gcc_ver(self):
        assert self.distro is Distro.ROBORIO_STD, "GCC check only works on roborio"
        cxx_headers = Path(self.sysroot, "usr/include/c++")
        assert cxx_headers.is_dir()
        children = list(cxx_headers.iterdir())
        assert len(children) == 1
        return os.path.basename(children[0])
