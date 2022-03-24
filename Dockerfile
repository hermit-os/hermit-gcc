FROM rust:buster as builder

RUN set -eux; \
    cargo install cargo-binutils; \
    cargo install cargo-download;

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        # gcc Build-Depends:
        bison \
        flex \
        libgmp-dev \
        libmpc-dev \
        libmpfr-dev \
        texinfo \
        # libhermit-rs Build-Depends:
        cmake \
        nasm \
    ; \
    rm -rf /var/lib/apt/lists/*;

ADD ./toolchain.sh .
RUN ./toolchain.sh x86_64-hermit /opt/hermit


FROM rust:buster as toolchain

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        # libhermit-rs Build-Depends:
        cmake \
        nasm \
    ; \
    rm -rf /var/lib/apt/lists/*;

COPY --from=builder $CARGO_HOME/bin/rust-objcopy $CARGO_HOME/bin/rust-objcopy
COPY --from=builder $CARGO_HOME/bin/cargo-download $CARGO_HOME/bin/cargo-download
COPY --from=builder /opt/hermit /opt/hermit
ENV PATH=/opt/hermit/bin:$PATH \
    LD_LIBRARY_PATH=/opt/hermit/lib:$LD_LIBRARY_PATH
