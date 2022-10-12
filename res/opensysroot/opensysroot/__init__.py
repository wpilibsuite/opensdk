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
    parser.add_argument("--minimal-toolchain",
                        default=False, action='store_true')
    return parser.parse_args()


def main():
    args = arg_info()
    repo_url = repo.get_repo_url(args.distro, args.arch)
    repo_packages_url = repo.get_repo_packages_url(
        args.distro, args.arch, args.release)

    env = WorkEnvironment(args.distro, args.arch, args.release,
                          args.output, args.print_dest_sysroot,
                          args.minimal_toolchain)

    db = Database(repo_packages_url)
    if args.distro in (Distro.ROBORIO, Distro.ROBORIO_ACADEMIC):
        assert args.arch is Arch.CORTEXA9
        db.add_package("libc6-dev")
        db.add_package("linux-libc-headers-dev")
        if not args.minimal_toolchain:
            db.add_package("gcc-dev")
            db.add_package("libstdc++-dev")
            db.add_package("libatomic-dev")
    else:
        assert args.arch is not Arch.CORTEXA9
        db.add_package("gcc")
        db.add_package("g++")
        if args.minimal_toolchain:
            raise RuntimeError("Minimal toolchain flag is unsupported for Debian targets")

    db.post_resolve()
    db.download(repo_url, env.downloads)
    env.extract()
    env.clean()
