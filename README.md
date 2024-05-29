# hermit-toolchain

This repository contains scripts to build the cross-compiler for the Rust-based library OS [HermitCore](https://github.com/hermit-os/libhermit-rs).

## Requirements

The build process works currently only on **x86-based Linux** systems. The following software packets are required to build HermitCore's toolchain on a Linux system:

* Netwide Assembler (NASM)
* GNU Make, GNU Binutils, cmake
* Tools and libraries to build *linux*, *binutils* and *gcc* (e.g. flex, bison, MPFR library, GMP library, MPC library)
* Rust

On Debian-based systems the packets can be installed by executing:
```
  sudo apt-get install cmake nasm libmpfr-dev libmpc-dev libgmp-dev flex bison
```

Note: If issues arise during the build, try using requirements.sh to check the versions of the necessary packets and the configuration of the LD_LIBRARY_PATH (it should contain the MPFR library, GMP library and MPC library).

## Building the HermitCore's toolchain

To build the toolchain just call the script as follow:

```bash
$ ./toolchain.sh x86_64-hermit /home/usr/hermit
```

The first argument of the script specifies the target architecture, where the second argument defines the path to the installation directory.
To create the toolchain, write access to the installation directory is required.
