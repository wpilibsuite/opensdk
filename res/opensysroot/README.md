# OpenSysroot tool

## Introduction

This project is a tool to function as a way for building sysroots of popular debian based
distributions, aswell as for the National Instruments RoboRIOs firmware. The latter is chosen to
support projects of the FIRST Robotics Competition such as the
[WPILib project](https://github.com/wpilibsuite/).

The purpous for creating this project is to help relieve the gap that exists in creating sysroots
for cross-compiling in various use cases or projects.

## Install

```sh
# From Source
python3 -m pip install .
```

## Usage

```sh
# Syntax
python3 -m opensysroot DISTRO ARCH RELEASE OUTPUT [EXTRA_ARGS]

# Ubuntu x86_64 Focal Fossa sysroot
python3 -m opensysroot ubuntu amd64 focal build_dir

# For more info
python3 -m opensysroot -h
```

## Licensing

Identifier: `BSD-3-Clause`

Refer to `LICENSE.md` for more info

