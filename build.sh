#!/usr/bin/env bash

set -e

[ -d joltc/JoltPhysics ] || git clone --recurse-submodules https://github.com/jrouwe/JoltPhysics -b v5.3.0 --depth=1 joltc/JoltPhysics

echo "Building joltc.."
cd joltc
cmake . -B build -DCPP_EXCEPTIONS_ENABLED=OFF -DCPP_RTTI_ENABLED=OFF -DJPH_BUILD_SHARED=OFF -DCMAKE_BUILD_TYPE=Release
if [ $(uname -s) = 'Darwin' ]; then
    make -j$(sysctl -n hw.ncpu) -C build
    LIB_EXT=darwin
else
    make -j$(nproc) -C build
    LIB_EXT=linux
fi

cp build/lib/libjoltc.a ../libjoltc.$LIB_EXT.a
