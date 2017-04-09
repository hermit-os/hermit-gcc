# hermit-bootstrap

This repository contains scripts to build the HermitCore's bootstrap compiler, which is the minimal version of the gcc to build the library OS [HermitCore](http://www.hermitcore.org).
To build the compiler just call the script as follow:

```bash
$ . ./bootstrap.sh x86_64-hermit /home/usr/hermit
```

The first argument of the script specifies the target architecture, where the second argument defines the path to the installation directory.
