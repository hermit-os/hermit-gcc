ARG ARCH
ARG TARGET=$ARCH-hermit
ARG PREFIX=/opt/hermit

FROM --platform=$BUILDPLATFORM rust:bookworm AS kernel
ADD --link https://github.com/hermit-os/kernel.git /kernel
WORKDIR /kernel
ARG ARCH
RUN cargo xtask build \
    --artifact-dir . \
    --arch $ARCH \
    --release \
    --no-default-features \
    --features pci,smp,acpi,newlib,tcp,dhcpv4

FROM buildpack-deps:bookworm AS binutils
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        bison \
        flex \
        texinfo \
    ; \
    rm -rf /var/lib/apt/lists/*;
ADD --link https://github.com/hermit-os/binutils.git /binutils
WORKDIR /binutils
ENV CFLAGS="-w" \
    CXXFLAGS="-w"
ARG TARGET
ARG PREFIX
RUN set -eux; \
    ./configure \
        --target=$TARGET \
        --prefix=$PREFIX \
        --with-sysroot \
        --disable-werror \
        --disable-multilib \
        --disable-shared \
        --disable-nls \
        --disable-gdb \
        --disable-libdecnumber \
        --disable-readline \
        --disable-sim \
        --enable-tls \
        --enable-lto \
        --enable-plugin; \
    make -O -j$(nproc); \
    make install; \
    make clean

FROM buildpack-deps:bookworm AS gcc
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
ARG TARGET
ARG PREFIX
COPY --link --from=binutils $PREFIX $PREFIX
ENV CFLAGS="-w" \
    CXXFLAGS="-w" \
    CFLAGS_FOR_TARGET="-fPIE -pie" \
    GOFLAGS_FOR_TARGET="-fPIE -pie" \
    FCFLAGS_FOR_TARGET="-fPIE -pie" \
    FFLAGS_FOR_TARGET="-fPIE -pie" \
    CXXFLAGS_FOR_TARGET="-fPIE -pie"

ADD --link https://github.com/hermit-os/gcc.git /gcc
WORKDIR /gcc/builddir-bootstrap
RUN set -eux; \
    ../configure \
        --target=$TARGET \
        --prefix=$PREFIX \
        --without-headers \
        --disable-multilib \
        --with-isl \
        --enable-languages=c,c++,lto \
        --disable-nls \
        --disable-shared \
        --disable-libssp \
        --disable-libgomp \
        --enable-threads=posix \
        --enable-tls \
        --enable-lto \
        --disable-symvers; \
    make -O -j$(nproc) all-gcc; \
    make install-gcc; \
    make clean
ENV PATH=$PREFIX/bin:$PATH

COPY --link --from=kernel /kernel/libhermit.a /kernel/libhermit.a
ENV LDFLAGS_FOR_TARGET="-L/kernel -Wl,--whole-archive -lhermit -Wl,--no-whole-archive"

ADD --link https://github.com/hermit-os/newlib.git /newlib
WORKDIR /newlib
RUN set -eux; \
    ./configure \
        --target=$TARGET \
        --prefix=$PREFIX \
        --disable-shared \
        --disable-multilib \
        --enable-lto \
        --enable-newlib-io-c99-formats \
        --enable-newlib-mb \
        --enable-newlib-multithread; \
    make -O -j$(nproc); \
    make install; \
    make clean

ADD --link https://github.com/hermit-os/pthread-embedded.git /pthread-embedded
WORKDIR /pthread-embedded
RUN set -eux; \
    ./configure \
        --target=$TARGET \
        --prefix=$PREFIX; \
    make -O -j$(nproc); \
    make install; \
    make clean

WORKDIR /gcc/builddir
RUN set -eux; \
    ../configure \
        --target=$TARGET \
        --prefix=$PREFIX \
        --with-newlib \
        --with-isl \
        --disable-multilib \
        --without-libatomic \
        --enable-languages=c,c++,fortran,lto \
        --disable-nls \
        --disable-shared \
        --enable-libssp \
        --enable-threads=posix \
        --enable-libgomp \
        --enable-tls \
        --enable-lto \
        --disable-symver; \
    make -O -j$(nproc); \
    make install; \
    make clean

FROM rust:bookworm AS toolchain
ARG PREFIX
COPY --from=gcc $PREFIX $PREFIX
ENV PATH=$PREFIX/bin:$PATH \
    LD_LIBRARY_PATH=$PREFIX/lib:$LD_LIBRARY_PATH
