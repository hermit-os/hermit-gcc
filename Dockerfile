FROM ubuntu:focal as builder

ENV DEBIAN_FRONTEND=noninteractive

ADD . /hermit
WORKDIR /hermit

# Update and install required packets from ubuntu repository
RUN apt-get clean && apt-get -qq update && apt-get install -y apt-transport-https curl wget git binutils autoconf automake make cmake nasm gcc g++ build-essential libtool bsdmainutils libssl-dev pkg-config lld libncurses5-dev python texinfo libmpfr-dev libmpc-dev libgmp-dev flex bison

# Install Rust toolchain
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain nightly
RUN /root/.cargo/bin/cargo install cargo-download
RUN /root/.cargo/bin/rustup component add rust-src
RUN /root/.cargo/bin/rustup component add llvm-tools-preview

ENV PATH=/opt/hermit/bin:/root/.cargo/bin:/root/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/lib/rustlib/x86_64-unknown-linux-gnu/bin/:$PATH
ENV LD_LIBRARY_PATH=/opt/hermit/lib:$LD_LIBRARY_PATH
RUN . cmake/local-cmake.sh
RUN ./toolchain.sh x86_64-hermit /opt/hermit

#Download base image ubuntu 20.04
FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH=/opt/hermit/bin:/root/.cargo/bin:/root/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/lib/rustlib/x86_64-unknown-linux-gnu/bin/:$PATH
ENV LD_LIBRARY_PATH=/opt/hermit/lib:$LD_LIBRARY_PATH

# Update Software repository
RUN apt-get clean && apt-get -qq update && apt-get install -y apt-transport-https vim curl wget git binutils autoconf automake make cmake nasm build-essential lld libncurses5

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain nightly
RUN /root/.cargo/bin/cargo install cargo-download
RUN /root/.cargo/bin/rustup component add rust-src
RUN /root/.cargo/bin/rustup component add llvm-tools-preview

COPY --from=builder /opt/hermit /opt/hermit
