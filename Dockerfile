FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

# Update and install required packets from ubuntu repository
RUN apt-get clean && apt-get -qq update && apt-get install -y apt-transport-https curl wget git binutils autoconf automake make cmake nasm gcc g++ build-essential libtool bsdmainutils libssl-dev pkg-config lld libncurses5-dev
