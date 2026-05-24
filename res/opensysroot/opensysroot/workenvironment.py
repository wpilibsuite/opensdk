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
    "usr/lib/{tuple}/audit",
    "usr/lib/{tuple}/ldscripts",
    "usr/lib/{tuple}/perl",
    "usr/lib/{tuple}/perl-base",
    "usr/lib/{tuple}/pkgconfig",
    "usr/lib/bfd-plugins",
    "usr/lib/compat-ld",
    "usr/lib/gold-ld",
    "usr/lib/{tuple}/dri",
    "usr/libexec"
]

SYSTEMCORE_TO_DELETE = [
    "lib",
    "lib64",
    "usr/lib64",
    "usr/build",
    "usr/build-1",
    "usr/cgi-bin",
    "usr/error",
    "usr/htdocs",
    "usr/include/absl",
    "usr/include/cairo",
    "usr/include/freetype2",
    "usr/include/fmt",
    "usr/include/eigen3",
    "usr/include/google",
    "usr/include/harfbuzz",
    "usr/include/json-c",
    "usr/include/ntcore",
    "usr/include/opencv4",
    "usr/include/pango-1.0",
    "usr/include/python3.13",
    "usr/include/upb",
    "usr/include/upb_generator",
    "usr/include/uv",
    "usr/include/uv.h",
    "usr/include/wpinet",
    "usr/include/wpiutil",
    "usr/lib/avahi",
    "usr/lib/binfmt.d",
    "usr/lib/credstore",
    "usr/lib/cmake/absl",
    "usr/lib/cmake/fmt",
    "usr/lib/cmake/opencv4",
    "usr/lib/cmake/harfbuzz",
    "usr/lib/cmake/json-c",
    "usr/lib/cmake/protobuf",
    "usr/lib/cmake/realsense2",
    "usr/lib/cmake/utf8_range", # upb dep
    "usr/lib/environment.d/99-environment.conf",
    "usr/lib/girepository-1.0",
    "usr/lib/gobject-introspection",
    "usr/lib/libdatalog.so",
    "usr/lib/libntcore.so",
    "usr/lib/libtraceevent",
    "usr/lib/libupb.a",
    "usr/lib/libwpinet.so",
    "usr/lib/libwpiutil.so",
    "usr/lib/modprobe.d",
    "usr/lib/modules-load.d",
    "usr/lib/pam.d",
    "usr/lib/pkgconfig/eigen3.pc",
    "usr/lib/pkgconfig/fmt.pc",
    "usr/lib/pkgconfig/freetype2.pc",
    "usr/lib/pkgconfig/json-c.pc",
    "usr/lib/pkgconfig/realsense2.pc",
    "usr/lib/pkgconfig/upb.pc",
    "usr/lib/pkgconfig/utf8_range.pc",
    "usr/lib/python3.13",
    "usr/lib/rpm",
    "usr/lib/security",
    "usr/lib/sysctl.d",
    "usr/lib/systemd",
    "usr/lib/sysusers.d",
    "usr/lib/terminfo",
    "usr/lib/tmpfiles.d",
    "usr/lib/udev",
    "usr/local",
    "usr/modules",
]

SYSTEMCORE_GLOBS_TO_DELETE = [
    "usr/include/libutf8*", # upb dep
    "usr/lib/go*",
    "usr/lib/libabsl*",
    "usr/lib/libcairo*",
    "usr/lib/libfmt*",
    "usr/lib/libfreetype*",
    "usr/lib/libharfbuzz*",
    "usr/lib/libjson-c*",
    "usr/lib/libopencv*",
    "usr/lib/libpango*",
    "usr/lib/libprotobuf*",
    "usr/lib/libprotoc*",
    "usr/lib/libpython*",
    "usr/lib/librealsense*",
    "usr/lib/libutf8*", # upb dep
    "usr/lib/libuv*",
    "usr/lib/pkgconfig/absl*",
    "usr/lib/pkgconfig/cairo*",
    "usr/lib/pkgconfig/harfbuzz*",
    "usr/lib/pkgconfig/pango*",
    "usr/lib/pkgconfig/protobuf*",
    "usr/lib/pkgconfig/python*",
]

SYSTEMCORE_TO_RENAME = [
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
            if self.distro is Distro.SYSTEMCORE:
                subprocess.call(["tar", "--strip-components=3", "-xf", str(file.absolute()), "systemcore-aarch64-toolchain/aarch64-buildroot-linux-gnu/sysroot"], cwd=self.sysroot)
                subprocess.call(["tar", "--strip-components=2", "-C", "usr", "-xf", str(file.absolute()), "systemcore-aarch64-toolchain/aarch64-buildroot-linux-gnu/include"], cwd=self.sysroot)
                path = "usr/lib/gcc/aarch64-linux-gnu/{}".format(self.get_gcc_ver())
                (self.sysroot / path).mkdir(parents=True, exist_ok=True)
                subprocess.call(["tar", "--strip-components=4", "-C", "usr/lib/gcc/aarch64-linux-gnu", "-xf", str(file.absolute()), "systemcore-aarch64-toolchain/lib/gcc/aarch64-buildroot-linux-gnu"], cwd=self.sysroot)
                subprocess.call(["tar", "--strip-components=3", "-C", path, "-xf", str(file.absolute()), "systemcore-aarch64-toolchain/aarch64-buildroot-linux-gnu/lib64"], cwd=self.sysroot)
                continue
            subprocess.call(["dpkg", "-x", str(file), str(self.sysroot)])

    def clean(self):
        self._delete(TO_DELETE)
        if self.distro is Distro.SYSTEMCORE:
            self._major_only(SYSTEMCORE_TO_RENAME)
            self._delete(SYSTEMCORE_TO_DELETE)
            for glob in SYSTEMCORE_GLOBS_TO_DELETE:
                for file in self.sysroot.glob(glob):
                    self._delete_path(file)
        self._symlink()

    def _major_only(self, paths):
        ver = self.get_gcc_ver()
        ver_major = ver.split(".")[0]
        tuple = self.get_orig_tuple()
        for dir in paths:
            oldname = dir.format(ver=ver, tuple=tuple)
            newname = dir.format(ver=ver_major, tuple=tuple)
            oldname = Path(self.sysroot, oldname)
            newname = Path(self.sysroot, newname)
            shutil.move(oldname, newname)

    def _delete_path(self, path: Path):
            if path.is_symlink():
                path.unlink()
            elif path.exists():
                if path.is_file():
                    path.unlink()
                else:
                    shutil.rmtree(path)

    def _delete(self, paths):
        tuple = self.get_orig_tuple()
        for subpath in paths:
            self._delete_path(Path(self.sysroot, subpath.format(tuple=tuple)))


    def _symlink(self):
        for file in self.sysroot.glob("**/*"):
            if not file.is_symlink():
                continue
            if "usr/bin" in str(file):
                continue
            resolved = Path(os.readlink(file))
            if resolved.is_absolute():
                resolved = Path("{}/{}".format(self.sysroot, resolved))
            else:
                resolved = Path(
                    "{}/{}".format(file.parent.absolute(), resolved))
            resolved = resolved.resolve()
            file.unlink()
            if resolved.is_dir():
                shutil.copytree(resolved, file)
            elif resolved.exists():
                shutil.copy2(resolved, file)

    def get_orig_tuple(self):
        if self.arch is Arch.ARM64:
            return "aarch64-linux-gnu"
        if self.arch is Arch.AMD64:
            return "x86_64-linux-gnu"
        raise RuntimeError("Unknown System")

    def get_gcc_ver(self):
        assert self.distro is Distro.SYSTEMCORE, "GCC check only works on Systemcore"
        cxx_headers = Path(self.sysroot, "usr/include/c++")
        assert cxx_headers.is_dir()
        children = list(cxx_headers.iterdir())
        assert len(children) == 1
        return os.path.basename(children[0])
