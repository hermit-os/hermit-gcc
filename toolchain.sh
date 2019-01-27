#!/bin/bash
#
# script to build HermitCore's toolchain
#
# $1 = specifies the target architecture
# $2 = specifies the installation directory

BUILDDIR=build
CLONE_DEPTH="--depth=50"
#PREFIX="$2"
#TARGET=$1
#TARGET_SHORT=${TARGET::-7}
TARGET=x86_64-unknown-linux-musl
PREFIX=/home/stefan/musl
NJOBS=-j"$(nproc)"
PATH=$PATH:$PREFIX/bin
#ARCH_OPT= #"-mtune=native"
#export CFLAGS_FOR_TARGET="-O2 $ARCH_OPT"
#export GOFLAGS_FOR_TARGET="-O2 $ARCH_OPT"
#export FCFLAGS_FOR_TARGET="-O2 $ARCH_OPT"
#export FFLAGS_FOR_TARGET="-O2 $ARCH_OPT"
#export CXXFLAGS_FOR_TARGET="-O2 $ARCH_OPT"

echo "Build bootstrap toolchain for $TARGET with $NJOBS jobs for $PREFIX"
sleep 1

mkdir -p $BUILDDIR
cd $BUILDDIR

if [ ! -d "binutils" ]; then
wget https://ftp-stud.hs-esslingen.de/pub/Mirrors/ftp.gnu.org/binutils/binutils-2.31.1.tar.gz
tar xzvf binutils-2.31.1.tar.gz
mv binutils-2.31.1 binutils
fi

if [ ! -d "musl" ]; then
git clone $CLONE_DEPTH https://github.com/hermitcore/musl.git
fi

if [ ! -d "gcc" ]; then
wget http://ftp.halifax.rwth-aachen.de/gnu/gcc/gcc-8.2.0/gcc-8.2.0.tar.gz
tar xzvf gcc-8.2.0.tar.gz
mv gcc-8.2.0 gcc
#wget ftp://gcc.gnu.org/pub/gcc/infrastructure/isl-0.18.tar.bz2 -O isl-0.18.tar.bz2
#tar jxf isl-0.18.tar.bz2
#mv isl-0.18 gcc/isl
fi

if [ ! -d "tmp/binutils" ]; then
mkdir -p tmp/binutils
cd tmp/binutils
../../binutils/configure --target=$TARGET --prefix=$PREFIX --with-sysroot --disable-multilib --disable-shared --disable-nls --disable-gdb --disable-libdecnumber --disable-readline --disable-sim --disable-libssp --enable-tls --enable-lto --enable-plugin && make $NJOBS && make install
cd -
fi

if [ ! -d "tmp/gcc" ]; then
mkdir -p tmp/gcc
cd tmp/gcc
../../gcc/configure --target=$TARGET --prefix=$PREFIX --with-isl --enable-default-pie --disable-multilib --without-headers --enable-languages=c,lto --enable-lto --disable-nls --disable-shared --disable-libssp --disable-quadmath --disable-libatomic --disable-libmudflap --disable-libgomp && make all-gcc && make install-gcc
cd -
fi

if [ ! -d "tmp/musl" ]; then
mkdir -p tmp/musl
cd tmp/musl
../../musl/configure --target=$TARGET --enable-optimization --exec-prefix=$PREFIX --prefix=$PREFIX/$TARGET --disable-shared && make $NJOBS && make install
cd -
fi

if [ ! -d "tmp/final" ]; then
mkdir -p tmp/final
cd tmp/final
../../gcc/configure --target=$TARGET --prefix=$PREFIX --with-isl --enable-default-pie --disable-multilib --enable-languages=c,c++,fortran,lto --disable-nls --disable-shared --disable-libssp --disable-libatomic --disable-libmpx --disable-libsanitizer --enable-libgomp --enable-threads=posix --enable-tls --enable-lto && make all && make install
cd -
fi
