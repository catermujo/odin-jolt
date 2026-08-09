#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
JOLTC_DIR="$ROOT_DIR/joltc"
JOLT_DIR="$JOLTC_DIR/JoltPhysics"
BUILD_DIR="$JOLTC_DIR/build_static"

if [ ! -d "$JOLT_DIR" ]; then
    git clone --recurse-submodules https://github.com/jrouwe/JoltPhysics -b v5.3.0 --depth=1 "$JOLT_DIR"
fi

linux_arch_dir() {
    case "$(uname -m)" in
        x86_64 | amd64) echo "linux_x64" ;;
        aarch64 | arm64) echo "linux_arm64" ;;
        *) echo "linux_$(uname -m)" ;;
    esac
}

darwin_arch_dir() {
    case "$(uname -m)" in
        x86_64 | amd64) echo "darwin_x64" ;;
        aarch64 | arm64) echo "darwin_arm64" ;;
        *) echo "darwin_$(uname -m)" ;;
    esac
}

HOST_OS="$(uname -s)"
if [ "$HOST_OS" = "Darwin" ]; then
    ARCH_DIR="$(darwin_arch_dir)"
    CPU="$(sysctl -n hw.ncpu)"
    OUTPUT="$BUILD_DIR/lib/libjoltc.a"
    LIB_NAME="joltc.darwin.a"
elif [ "$HOST_OS" = "Linux" ]; then
    ARCH_DIR="$(linux_arch_dir)"
    CPU="$(nproc)"
    OUTPUT="$BUILD_DIR/lib/libjoltc.a"
    LIB_NAME="joltc.linux.a"
else
    echo "unsupported host OS: $HOST_OS" >&2
    exit 1
fi

echo "Configuring static joltc..."
cmake -S "$JOLTC_DIR" -B "$BUILD_DIR" \
    -DCPP_EXCEPTIONS_ENABLED=OFF \
    -DCPP_RTTI_ENABLED=OFF \
    -DJPH_BUILD_SHARED=OFF \
    -DJPH_INSTALL=OFF \
    -DJPH_SAMPLES=OFF \
    -DCMAKE_BUILD_TYPE=Release

echo "Building static joltc..."
cmake --build "$BUILD_DIR" --config Release -j"$CPU"

mkdir -p "$ROOT_DIR/$ARCH_DIR"
cp "$OUTPUT" "$ROOT_DIR/$ARCH_DIR/$LIB_NAME"
