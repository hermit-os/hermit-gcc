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
TARGET_SHORT=${TARGET::-7}
NJOBS=-j"$(nproc)"
PATH=$PATH:$PREFIX/bin
ARCH_OPT= #"-mtune=native"
export CFLAGS_FOR_TARGET="-O3 -ftree-vectorize $ARCH_OPT"
export GOFLAGS_FOR_TARGET="-O3 -ftree-vectorize $ARCH_OPT"
export FCFLAGS_FOR_TARGET="-O3 -ftree-vectorize $ARCH_OPT"
export FFLAGS_FOR_TARGET="-O3 -ftree-vectorize $ARCH_OPT"
export CXXFLAGS_FOR_TARGET="-O3 -ftree-vectorize $ARCH_OPT"

echo "Build bootstrap toolchain for $TARGET with $NJOBS jobs for $PREFIX"
sleep 1

mkdir -p $BUILDDIR
cd $BUILDDIR

if [ ! -d "binutils" ]; then
git clone $CLONE_DEPTH https://github.com/hermitcore/binutils.git
fi

if [ ! -d "gcc" ]; then
git clone $CLONE_DEPTH https://github.com/hermitcore/gcc.git
wget ftp://gcc.gnu.org/pub/gcc/infrastructure/isl-0.15.tar.bz2 -O isl-0.15.tar.bz2
tar jxf isl-0.15.tar.bz2
mv isl-0.15 gcc/isl
fi

if [ ! -d "hermit" ]; then
git clone --recursive https://github.com/hermitcore/libhermit.git hermit
fi

if [ ! -d "newlib" ]; then
git clone $CLONE_DEPTH https://github.com/hermitcore/newlib.git
fi

if [ ! -d "pte" ]; then
git clone $CLONE_DEPTH https://github.com/hermitcore/pthread-embedded.git pte
cd pte
./configure --prefix=$PREFIX --target=$TARGET
cd -
fi

if [ ! -d "openmp" ]; then
git clone $CLONE_DEPTH https://github.com/hermitcore/openmp.git
fi

if [ ! -d "tmp/binutils" ]; then
mkdir -p tmp/binutils
cd tmp/binutils
../../binutils/configure --target=$TARGET --prefix=$PREFIX --with-sysroot --disable-multilib --disable-shared --disable-nls --disable-gdb --disable-libdecnumber --disable-readline --disable-sim --disable-libssp --enable-tls --enable-lto --enable-plugin
make $NJOBS
make install
cd -
fi

if [ ! -d "tmp/bootstrap" ]; then
mkdir -p tmp/bootstrap
cd tmp/bootstrap
../../gcc/configure --target=$TARGET --prefix=$PREFIX --without-headers --disable-multilib --with-isl --enable-languages=c,c++,lto --disable-nls --disable-shared --disable-libssp --disable-libgomp --enable-threads=posix --enable-tls --enable-lto --disable-symvers
make $NJOBS all-gcc
make install-gcc
cd -
fi

if [ ! -d "tmp/hermit" ]; then
mkdir -p tmp/hermit
cd tmp/hermit
cmake -DHERMIT_ARCH=$TARGET_SHORT -DTOOLCHAIN_BIN_DIR=$PREFIX/bin -DCMAKE_INSTALL_PREFIX=$PREFIX -DBOOTSTRAP=true ../../hermit
make hermit-bootstrap
make hermit-bootstrap-install
cd -
fi

if [ ! -d "tmp/newlib" ]; then
mkdir -p tmp/newlib
cd tmp/newlib
../../newlib/configure --target=$TARGET --prefix=$PREFIX --disable-shared --disable-multilib --enable-lto --enable-newlib-hw-fp --enable-newlib-io-c99-formats --enable-newlib-multithread && make $NJOBS all-target-newlib && make install-target-newlib
cd -
fi

cd pte
make && make install
cd ..

if [ ! -d "tmp/gcc" ]; then
mkdir -p tmp/gcc
cd tmp/gcc
../../gcc/configure --target=$TARGET --prefix=$PREFIX --with-newlib --with-isl --disable-multilib --without-libatomic --enable-languages=c,c++,fortran,go,lto --disable-nls --disable-shared --disable-libssp --enable-threads=posix --disable-libgomp --enable-tls --enable-lto --disable-symver
make $NJOBS
make install
cd -
fi

if [ ! -d "tmp/openmp" ]; then
mkdir -p tmp/openmp
cd tmp/openmp
cmake -DLIBOMP_ARCH=$TARGET_SHORT -DCMAKE_C_COMPILER=$TARGET-gcc -DCMAKE_CXX_COMPILER=$TARGET-g++ -DCMAKE_INSTALL_PREFIX=$PREFIX/$TARGET -DCMAKE_TRY_COMPILE_TARGET_TYPE=STATIC_LIBRARY -DHERMIT=1 -DLIBOMP_ENABLE_SHARED=OFF -DLIBOMP_FORTRAN_MODULES=OFF -DLIBOMP_OMPT_SUPPORT=OFF -DOPENMP_ENABLE_LIBOMPTARGET=OFF ../../openmp
make
make install
cd -
fi

if [ ! -d "tmp/final" ]; then
mkdir -p tmp/final
cd tmp/final
cmake -DTOOLCHAIN_BIN_DIR=$PREFIX/bin -DCMAKE_INSTALL_PREFIX=$PREFIX -DMTUNE=native ../../hermit
make
make install
cd -
fi

cd ..
