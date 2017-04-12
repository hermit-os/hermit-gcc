# hermit-toolchain

This repository contains scripts to build the HermitCore's cross-compiler, which based on the library OS [HermitCore](http://www.hermitcore.org).

## Requirements

The build process works currently only on **x86-based Linux** systems. The following software packets are required to build HermitCore's toolchain on a Linux system:

* Netwide Assembler (NASM)
* GNU Make, GNU Binutils, cmake
* Tools and libraries to build *linux*, *binutils* and *gcc* (e.g. flex, bison, MPFR library, GMP library, MPC library)
* texinfo

On Debian-based systems the packets can be installed by executing:
```
  sudo apt-get install nasm texinfo libmpfr-dev libmpc-dev libgmp-dev flex bison
```

We require a fairly recent version of CMake (`3.7`) which is not yet present in
most Linux distributions. We therefore provide a helper script that fetches the
required CMake binaries from the upstream project and stores them locally, so
you only need to download it once.

```bash
$ . cmake/local-cmake.sh
-- Downloading CMake
--2017-03-28 16:13:37--  https://cmake.org/files/v3.7/cmake-3.7.2-Linux-x86_64.tar.gz
Loaded CA certificate '/etc/ssl/certs/ca-certificates.crt'
Resolving cmake.org... 66.194.253.19
Connecting to cmake.org|66.194.253.19|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 30681434 (29M) [application/x-gzip]
Saving to: ‘cmake-3.7.2-Linux-x86_64.tar.gz’

cmake-3.7.2-Linux-x86_64.tar.gz         100%[===================>]  29,26M  3,74MB/s    in 12s     

2017-03-28 16:13:50 (2,48 MB/s) - ‘cmake-3.7.2-Linux-x86_64.tar.gz’ saved [30681434/30681434]

-- Unpacking CMake
-- Local CMake v3.7.2 installed to cmake/cmake-3.7.2-Linux-x86_64
-- Next time you source this script, no download will be neccessary
```

So before you build HermitCore's toolchain you have to source the `local-cmake.sh` script
everytime you open a new terminal.

## Building the HermitCore's toolchain

To build the toolchain just call the script as follow:

```bash
$ . ./toolchain.sh x86_64-hermit /home/usr/hermit
```

The first argument of the script specifies the target architecture, where the second argument defines the path to the installation directory.
Do create the toolchain, write access to the installation directory is required.
