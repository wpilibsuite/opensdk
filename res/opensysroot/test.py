from opensysroot import *
import re

foo = re.compile(r"(ipk|deb) (\S+) (\S+) (\S+)")

a = repo.get_repo_urls(Distro.DEBIAN, Arch.AMD64, Release.BOOKWORK)
print(a)
a = repo.get_repo_urls(Distro.ROBORIO_ACADEMIC, Arch.CORTEXA9, Release.NI2023)
for i in a:
    print(i)
