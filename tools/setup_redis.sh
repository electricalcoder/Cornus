#!/bin/bash

cd $HOME
# Clone the project
git clone https://github.com/cpp-redis/cpp_redis.git
# Go inside the project directory
cd cpp_redis
# Get tacopie submodule
git submodule update --init --recursive
cd tacopie
mkdir -p build && cd build
cmake ../ -DCMAKE_BUILD_TYPE=Release
make -j4
make install
cd ../../
# Create a build directory and move into it
mkdir -p build && cd build
# Generate the Makefile using CMake
cmake .. -DCMAKE_BUILD_TYPE=Release
# Build the library
make -j4
# Install the library
make install
