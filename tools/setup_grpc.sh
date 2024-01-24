#!/bin/bash

# dependencies
apt-get -y install build-essential autoconf libtool pkg-config
apt-get -y install cmake
apt-get -y install libgflags-dev
apt-get -y install clang-5.0 libc++-dev
apt update
apt -y install python3-pip
pip3 install pandas

# update cmake
#cd $HOME
#MY_INSTAL_DIR=${HOME}/cmake
#mkdir -p $MY_INSTAL_DIR
#wget -q -O cmake-linux.sh https://github.com/Kitware/CMake/releases/download/v3.19.6/cmake-3.19.6-Linux-x86_64.sh
#sh cmake-linux.sh -- --skip-license --prefix=$MY_INSTALL_DIR
#rm cmake-linux.sh

# install grpc
# make sure no libprotobuf installed before using this script
cd $HOME
git clone https://github.com/grpc/grpc
cd grpc
git submodule update --init --recursive
cd test/distrib/cpp/
cp ${HOME}/Sundial-Private/tools/run_distrib_test_cmake.sh ./
./run_distrib_test_cmake.sh
export PKG_CONFIG_PATH=/usr/local/grpc/lib/pkgconfig
export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
