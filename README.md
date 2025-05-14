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

To compile Hermit applications using this image, you need a built [Hermit kernel] (`libhermit.a`).
You can then compile applications like this (adapt to your desired target architecture):

[Hermit kernel]: https://github.com/hermit-os/kernel

```bash
docker run --rm -v .:/mnt -w /mnt ghcr.io/hermit-os/hermit-gcc:x86_64 x86_64-hermit-gcc -o app app.c libhermit.a
```

You can also use the image interactively:

```bash
docker run --rm -it -v .:/mnt -w /mnt ghcr.io/hermit-os/hermit-gcc:x86_64
```
