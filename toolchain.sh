#!/bin/bash
#
# script to build HermitCore's toolchain
#
# $1 = specifies the target architecture
# $2 = specifies the installation directory

# exit when any command fails
set -e

PREFIX="$2"
TARGET=$1
NJOBS=-j"$(nproc)"
PATH=$PATH:$PREFIX/bin
export CFLAGS="-w"
export CXXFLAGS="-w"
export CFLAGS_FOR_TARGET="-fPIE -pie"
export GOFLAGS_FOR_TARGET="-fPIE -pie"
export FCFLAGS_FOR_TARGET="-fPIE -pie"
export FFLAGS_FOR_TARGET="-fPIE -pie"
export CXXFLAGS_FOR_TARGET="-fPIE -pie"

echo "Build bootstrap toolchain for $TARGET with $NJOBS jobs for $PREFIX"

if [ ! -d "tmp/binutils" ]; then
mkdir -p tmp/binutils
cd tmp/binutils
../../binutils/configure \
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
    --enable-plugin
make -O $NJOBS
make install
cd -
fi

if [ ! -d "tmp/bootstrap" ]; then
mkdir -p tmp/bootstrap
cd tmp/bootstrap
../../gcc/configure \
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
    --disable-symvers
make -O $NJOBS all-gcc
make install-gcc
cd -
fi

cd kernel
cargo xtask build \
    --arch x86_64 \
    --release \
    --no-default-features \
    --features pci,smp,acpi,newlib,tcp,dhcpv4
export LDFLAGS_FOR_TARGET="-L$PWD/target/x86_64/release -lhermit"
cd -

if [ ! -d "tmp/newlib" ]; then
mkdir -p tmp/newlib
cd tmp/newlib
../../newlib/configure \
    --target=$TARGET \
    --prefix=$PREFIX \
    --disable-shared \
    --disable-multilib \
    --enable-lto \
    --enable-newlib-io-c99-formats \
    --enable-newlib-multithread
make -O $NJOBS
make install
cd -
fi

cd pte
./configure \
    --target=$TARGET \
    --prefix=$PREFIX
make -O $NJOBS
make install
cd ..

if [ ! -d "tmp/gcc" ]; then
mkdir -p tmp/gcc
cd tmp/gcc
../../gcc/configure \
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
    --disable-symver
make -O $NJOBS
make install
cd -
fi
