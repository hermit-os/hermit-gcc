FROM ubuntu:latest as builder

ENV DEBIAN_FRONTEND=noninteractive

ADD . /hermit
WORKDIR /hermit

# Update and install required packets from ubuntu repository
RUN apt-get clean && apt-get -qq update && apt-get install -y apt-transport-https curl wget git binutils autoconf automake make cmake nasm gcc g++ build-essential libtool bsdmainutils libssl-dev pkg-config lld libncurses5-dev python texinfo libmpfr-dev libmpc-dev libgmp-dev flex bison

ENV PATH=/opt/hermit/bin:$PATH
ENV LD_LIBRARY_PATH=/opt/hermit/lib:$LD_LIBRARY_PATH
RUN . cmake/local-cmake.sh
RUN ./toolchain.sh x86_64-hermit /opt/hermit

#Download base image ubuntu 18.04
FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

# Update Software repository
RUN apt-get clean && apt-get -qq update && apt-get install -y apt-transport-https vim curl wget git binutils autoconf automake make cmake nasm gcc g++ build-essential libtool bsdmainutils libssl-dev pkg-config lld libncurses5-dev python texinfo libmpfr-dev libmpc-dev libgmp-dev flex bison

COPY --from=builder /opt/hermit /opt/hermit
