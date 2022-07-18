
from setuptools import setup

setup(
    name='opensysroot',
    version='0.0.1',
    packages=[
        'opensysroot',
        'opensysroot/db',
        'opensysroot/db/parse',
        'opensysroot/enums',
    ],
    install_requires=[
        'requests',
    ],
)