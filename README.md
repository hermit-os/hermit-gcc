# hermit-toolchain

This repository contains scripts to build the HermitCore's cross-compiler, which based on the library OS [HermitCore](http://www.hermitcore.org).
To build the toolchain just call the script as follow:

```bash
$ . ./local-cmake.sh
$ . ./bootstrap.sh x86_64-hermit /home/usr/hermit
```

The first argument of the script specifies the target architecture, where the second argument defines the path to the installation directory.
Do create the toolchain, write access to the installation directory is required.
