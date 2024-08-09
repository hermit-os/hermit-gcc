ARG TARGET=x86_64-hermit
ARG PREFIX=/opt/hermit

FROM --platform=$BUILDPLATFORM rust:bookworm AS kernel
ADD --link https://github.com/hermit-os/kernel.git /kernel
WORKDIR /kernel
RUN cargo xtask build \
    --artifact-dir . \
    --arch x86_64 \
    --release \
    --no-default-features \
    --features pci,smp,acpi,newlib,tcp,dhcpv4

FROM buildpack-deps:bookworm AS builder

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        bison \
        flex \
        libgmp-dev \
        libisl-dev \
        libmpc-dev \
        libmpfr-dev \
        texinfo \
    ; \
    rm -rf /var/lib/apt/lists/*;

WORKDIR /root

COPY --link --from=kernel /kernel/libhermit.a /root/kernel/libhermit.a
ENV LDFLAGS_FOR_TARGET="-L/root/kernel -lhermit"

ADD --link https://github.com/hermit-os/binutils.git binutils
ADD --link https://github.com/hermit-os/gcc.git gcc
ADD --link https://github.com/hermit-os/kernel.git kernel
ADD --link https://github.com/hermit-os/newlib.git newlib
ADD --link https://github.com/hermit-os/pthread-embedded.git pte
ADD --link ./toolchain.sh ./toolchain.sh

ARG TARGET
ARG PREFIX
RUN ./toolchain.sh $TARGET $PREFIX


FROM rust:bookworm AS toolchain
ARG PREFIX
COPY --from=builder $PREFIX $PREFIX
ENV PATH=$PREFIX/bin:$PATH \
    LD_LIBRARY_PATH=$PREFIX/lib:$LD_LIBRARY_PATH
