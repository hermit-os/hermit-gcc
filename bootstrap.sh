#!/bin/bash
#
# script to build HermitCore's bootstrap compiler
#
# $1 = specifies the target architecture
# $2 = specifies the installation directory

BUILDDIR=build
CLONE_DEPTH="--depth=50"
PREFIX="$2"
TARGET=$1
NJOBS=-j"$(nproc)"
PATH=$PATH:$PREFIX/bin
ARCH_OPT="-mtune=native"
export CFLAGS_FOR_TARGET="-m64 -O3 -ftree-vectorize $ARCH_OPT"
export GOFLAGS_FOR_TARGET="-m64 -O3 -ftree-vectorize $ARCH_OPT"
export FCFLAGS_FOR_TARGET="-m64 -O3 -ftree-vectorize $ARCH_OPT"
export FFLAGS_FOR_TARGET="-m64 -O3 -ftree-vectorize $ARCH_OPT"
export CXXFLAGS_FOR_TARGET="-m64 -O3 -ftree-vectorize $ARCH_OPT"

echo "Build bootstrap toolchain for $TARGET with $NJOBS jobs for $PREFIX"
sleep 1

mkdir -p $BUILDDIR
cd $BUILDDIR

if [ ! -d "binutils" ]; then
git clone $CLONE_DEPTH https://github.com/RWTH-OS/binutils.git
fi

if [ ! -d "gcc" ]; then
git clone $CLONE_DEPTH https://github.com/RWTH-OS/gcc.git
wget ftp://gcc.gnu.org/pub/gcc/infrastructure/isl-0.15.tar.bz2 -O isl-0.15.tar.bz2
tar jxf isl-0.15.tar.bz2
mv isl-0.15 gcc/isl
fi

if [ ! -d "tmp/binutils" ]; then
mkdir -p tmp/binutils
cd tmp/binutils
../../binutils/configure --target=$TARGET --prefix=$PREFIX --with-sysroot --disable-multilib --disable-shared --disable-nls --disable-gdb --disable-libdecnumber --disable-readline --disable-sim --disable-libssp --enable-tls --enable-lto --enable-plugin && make $NJOBS && make install
cd -
fi

if [ ! -d "tmp/bootstrap" ]; then
mkdir -p tmp/bootstrap
cd tmp/bootstrap
../../gcc/configure --target=$TARGET --prefix=$PREFIX --without-headers --disable-multilib --with-isl --enable-languages=c,c++,lto --disable-nls --disable-shared --disable-libssp --disable-libgomp --enable-threads=posix --enable-tls --enable-lto --disable-symvers && make $NJOBS all-gcc && make install-gcc
cd -
fi
