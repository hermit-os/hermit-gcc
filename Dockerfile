FROM rust:buster as builder

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        # gcc Build-Depends:
        bison \
        git \
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

WORKDIR /root/
ADD ./toolchain.sh /root/toolchain.sh
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

COPY --from=builder /opt/hermit /opt/hermit
ENV PATH=/opt/hermit/bin:$PATH \
    LD_LIBRARY_PATH=/opt/hermit/lib:$LD_LIBRARY_PATH
