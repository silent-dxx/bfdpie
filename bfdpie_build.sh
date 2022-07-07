#!/bin/bash

# Break on error
set -e

#
# Sanity checks
#
INVOKEDIR="$(pwd)"
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ ! $INVOKEDIR = $BASEDIR ]; then
   echo "Must execute this from within the script's directory!"
   exit 1
fi
##

CURRENT_DIR=`pwd`
INSTALL_DIR=${CURRENT_DIR}/tmp/install
BUILD_DIR=${CURRENT_DIR}/tmp/build
PREFIX="multiarch-"
BINUTILS_VERSION=$1

if [ `uname -s` = "Cygwin" ]
then
	# Cygwin specific stuff
	C_FLAGS=""
else
	# Other UNIX (Linux, etc.) specific stuff
	C_FLAGS="-fPIC"
fi

# Clean up the build directory
rm -rf tmp
mkdir -p tmp/build

# Download binutils
wget -c http://ftp.gnu.org/gnu/binutils/${BINUTILS_VERSION}.tar.bz2 -O binutils.tar.bz2

# Extract
tar xvf binutils.tar.bz2 -C ${BUILD_DIR} --strip-components=1

# Go to the build directory
cd ${BUILD_DIR}

CFLAGS="$C_FLAGS -Wno-error=unused-value" ./configure --program-prefix=$PREFIX --enable-targets=all --prefix=$INSTALL_DIR --disable-ld --disable-nls --enable-64-bit-bfd --disable-werror

make -j
make install

# Copy over libiberty.a into the install folder
find ${BUILD_DIR} -name libiberty.a -exec cp {} ${INSTALL_DIR}/lib \;

