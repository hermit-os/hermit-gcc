#!/bin/bash
#
# script to build HermitCore's toolchain
#
# $1 = specifies the target architecture
# $2 = specifies the installation directory

# exit when any command fails
set -e

BUILDDIR=build
CLONE_DEPTH="--depth=50"
PREFIX="$2"
TARGET=$1
NJOBS=-j"$(nproc)"
PATH=$PATH:$PREFIX/bin
export CFLAGS="-w"
export CXXFLAGS="-w"
export CFLAGS_FOR_TARGET="-m64 -O3 -fPIE"
export GOFLAGS_FOR_TARGET="-m64 -O3 -fPIE"
export FCFLAGS_FOR_TARGET="-m64 -O3 -fPIE"
export FFLAGS_FOR_TARGET="-m64 -O3 -fPIE"
export CXXFLAGS_FOR_TARGET="-m64 -O3 -fPIE"

echo "Build bootstrap toolchain for $TARGET with $NJOBS jobs for $PREFIX"

mkdir -p $BUILDDIR
cd $BUILDDIR

if [ ! -d "binutils" ]; then
git clone $CLONE_DEPTH https://github.com/hermit-os/binutils.git
fi

if [ ! -d "gcc" ]; then
git clone $CLONE_DEPTH https://github.com/hermit-os/gcc.git
wget ftp://gcc.gnu.org/pub/gcc/infrastructure/isl-0.15.tar.bz2 -O isl-0.15.tar.bz2
tar jxf isl-0.15.tar.bz2
mv isl-0.15 gcc/isl
fi

if [ ! -d "hermit" ]; then
git clone --recursive -b master https://github.com/hermit-os/hermit-playground hermit
pushd hermit/librs
# See https://github.com/hermit-os/libhermit-rs/issues/597
cargo update --package time --precise 0.3.11
popd
fi

if [ ! -d "kernel" ]; then
git clone https://github.com/hermit-os/kernel
fi

if [ ! -d "newlib" ]; then
git clone $CLONE_DEPTH -b path2rs https://github.com/hermit-os/newlib.git
fi

if [ ! -d "pte" ]; then
git clone $CLONE_DEPTH -b path2rs https://github.com/hermit-os/pthread-embedded.git pte
cd pte
./configure --target=$TARGET --prefix=$PREFIX
cd -
fi

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

cp -r hermit/include $PREFIX/x86_64-hermit

cd kernel
cargo xtask build \
    --arch x86_64 \
    --release \
    --no-default-features \
    --features pci,smp,acpi,newlib,tcp,dhcpv4
cp target/x86_64/release/libhermit.a $PREFIX/x86_64-hermit/lib
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
make && make install
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

cd ..
