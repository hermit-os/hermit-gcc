# hermit-gcc

This repository provides an OCI image ([`ghcr.io/hermit-os/hermit-gcc`], [`Dockerfile`]) containing the GCC cross-compiler for the [Hermit Operating System].

[`ghcr.io/hermit-os/hermit-gcc`]: https://github.com/hermit-os/hermit-gcc/pkgs/container/hermit-gcc
[`Dockerfile`]: Dockerfile
[Hermit Operating System]: http://hermit-os.org

## Available Components

- [hermit-os/binutils](https://github.com/hermit-os/binutils)
- [hermit-os/newlib](https://github.com/hermit-os/newlib)
- [hermit-os/pthread-embedded](https://github.com/hermit-os/pthread-embedded)
- [hermit-os/gcc](https://github.com/hermit-os/gcc)

## Usage

You can use this image to run the compiler in the current directory using Docker:

```bash
docker run --rm -v .:/mnt -w /mnt ghcr.io/hermit-os/hermit-gcc:x86_64 x86_64-hermit-gcc --version
```

You can also use the image interactively:

```bash
docker run --rm -it -v .:/mnt -w /mnt ghcr.io/hermit-os/hermit-gcc:x86_64
```

For details on compiling C code for Hermit, see [hermit-c](https://github.com/hermit-os/hermit-c).
