#!/bin/bash

if echo "$LD_LIBRARY_PATH" | grep -q libgmp && echo "$LD_LIBRARY_PATH" | grep -q libisl && echo "$LD_LIBRARY_PATH" | grep -q libmpc && echo "$LD_LIBRARY_PATH" | grep -q libmpfr; then
    echo "LD_LIBRARY_PATH contains MPFR library, ISL library, GMP library, and MPC library"
elif ! echo "$LD_LIBRARY_PATH" | grep -q libgmp; then
    echo "LD_LIBRARY_PATH missing GMP library"
elif ! echo "$LD_LIBRARY_PATH" | grep -q libisl; then
    echo "LD_LIBRARY_PATH missing ISL library"
elif ! echo "$LD_LIBRARY_PATH" | grep -q libmpc; then
    echo "LD_LIBRARY_PATH missing MPC library"
elif ! echo "$LD_LIBRARY_PATH" | grep -q libmpfr; then
    echo "LD_LIBRARY_PATH missing MPFR library"
fi

check_version() {
    package=$1
    version_command=$2

    echo -n "Checking $package... "
    if $version_command &> /dev/null; then
        version=$($version_command | head -n 1)
        echo "Installed ($version)"
    else
        echo "Not installed"
    fi
}

# Check versions of packages
check_version "CMake" "cmake --version"
check_version "NASM" "nasm -v"
check_version "Flex" "flex --version"
check_version "Bison" "bison --version"