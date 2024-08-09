FROM rust:bookworm AS builder

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

ADD --link https://github.com/hermit-os/binutils.git binutils
ADD --link https://github.com/hermit-os/gcc.git gcc
ADD --link https://github.com/hermit-os/kernel.git kernel
ADD --link https://github.com/hermit-os/newlib.git newlib
ADD --link https://github.com/hermit-os/pthread-embedded.git pte
ADD --link ./toolchain.sh ./toolchain.sh

RUN ./toolchain.sh x86_64-hermit /opt/hermit


FROM rust:bookworm AS toolchain
COPY --from=builder /opt/hermit /opt/hermit
ENV PATH=/opt/hermit/bin:$PATH \
    LD_LIBRARY_PATH=/opt/hermit/lib:$LD_LIBRARY_PATH
