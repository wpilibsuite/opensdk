#! /usr/bin/env bash

# Core flags
CFLAGS="$CFLAGS -fPIC"
CXXFLAGS="$CXXFLAGS -fPIC"
export CFLAGS CXXFLAGS

# Flags to build toolchain gcc
GCC_CFLAGS="$CFLAGS --std=c99"
GCC_CXXFLAGS="$CXXFLAGS --std=c++98"
export GCC_CFLAGS GCC_CXXFLAGS

# Flags to build toolchain gdb
GDB_CFLAGS="$CFLAGS --std=gnu11"
GDB_CXXFLAGS="$CXXFLAGS --std=c++11"
export GDB_CFLAGS GDB_CXXFLAGS

# Make-server processes
JOBS="$(nproc --ignore=1)"
is-actions && JOBS="6" # Use the same across all actions
export JOBS
