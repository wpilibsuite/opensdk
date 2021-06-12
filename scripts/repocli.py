#! /usr/bin/env python3

from librepo import AptRepo
import sys


def args():
    distro = sys.argv[1]
    release = sys.argv[2]
    arch = sys.argv[3]
    if distro == "ni":
        release = ""
        arch = "cortexa9-vfpv3"
    return {
        "distro": distro,
        "release": release,
        "arch": arch,
        "out": sys.argv[4],
        "packages": sys.argv[5:]
    }


def main():
    _args = args()
    repo = AptRepo(_args["distro"], _args["release"],
                   _args["arch"])
    try:
        for pkg in _args["packages"]:
            repo.find_pkg(pkg).download(_args["out"], log=True)
    except OSError as e:
        # Server Error
        print(e)
        exit(1)
    except ValueError as e:
        # User error
        print(e)
        exit(1)

main()
