import argparse
from pathlib import Path

from . import repo
from .db import Database
from .workenvironment import WorkEnvironment
from .enums.arch import Arch
from .enums.distro import Distro
from .enums.release import Release


def arg_info():
    parser = argparse.ArgumentParser(prog="opensysroot",
                                     description="Sysroot construction for compiling")
    parser.add_argument("distro", type=Distro, choices=list(Distro),
                        help="Distro Name of OS that sysroot is based on")
    parser.add_argument("arch", type=Arch, choices=list(Arch),
                        help="Architecture OS that sysroot is based on")
    parser.add_argument("release", type=Release, choices=list(Release),
                        help="Release name of OS")
    parser.add_argument("output", type=Path, default=Path("build"))
    parser.add_argument("--print-dest-sysroot",
                        default=False, action='store_true')
    return parser.parse_args()


def main():
    args = arg_info()
    if args.distro in (Distro.ROBORIO_STD, Distro.ROBORIO_ACADEMIC, Distro.SYSTEMCORE):
        repo_url = repo.get_repo_url_adv(args.distro, args.arch, args.release)
    else:
        repo_url = repo.get_repo_url(args.distro, args.arch)
    repo_packages_url = repo.get_repo_packages_url(
        args.distro, args.arch, args.release)

    env = WorkEnvironment(args.distro, args.arch, args.release,
                          args.output, args.print_dest_sysroot)

    db = Database(repo_packages_url)
    if args.distro in (Distro.ROBORIO_STD, Distro.ROBORIO_ACADEMIC):
        assert args.arch is Arch.CORTEXA9
        db.add_package("libc6-dev")
        db.add_package("linux-libc-headers-dev")
        db.add_package("gcc-dev")
        db.add_package("libstdc++-dev")
        db.add_package("libatomic-dev")
        # debug symbols for remote debugging
        db.add_package("libc6-dbg")
        db.add_package("libgcc-s-dbg")
        db.add_package("gcc-runtime-dbg")
    elif args.distro == Distro.SYSTEMCORE:
        db.PACKAGES_TO_INSTALL['toolchain'] = {"name": "toolchain", "filename": "systemcore-aarch64-toolchain.tar.gz"}
    else:
        assert args.arch is not Arch.CORTEXA9
        db.add_package("gcc")
        db.add_package("g++")

        # Packages for GLFW
        db.add_package("libx11-dev")
        db.add_package("libxcursor-dev")
        db.add_package("libxrandr-dev")
        db.add_package("libxinerama-dev")
        db.add_package("libxi-dev")
        db.add_package("mesa-common-dev")

    db.post_resolve()
    db.download(repo_url, env.downloads)
    env.extract()
    env.clean()
