#!/bin/bash
# ── EverFree — Build Script ───────────────────────────────────────────────────
#
# Usage:
#   ./build.sh              # Default Release build
#   ./build.sh Debug        # Debug build
#   ./build.sh Release /path/to/Qt6  # With explicit Qt6 path
#

set -e

BUILD_TYPE="${1:-Release}"
QT_PREFIX_PATH="${2:-}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/build"

echo "╔══════════════════════════════════════════════╗"
echo "║  EverFree — Build Script                     ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
echo "Build type: $BUILD_TYPE"
echo "Build dir:  $BUILD_DIR"
echo ""

# ── Check dependencies ────────────────────────────────────────────────────────

check_dep() {
    if ! command -v "$1" &> /dev/null && ! pkg-config --exists "$2" 2>/dev/null; then
        echo "⚠️  $1 not found — install: $3"
        return 1
    fi
    echo "✅ $1 found"
    return 0
}

MISSING_DEPS=0

check_dep "cmake" "" "sudo apt install cmake" || MISSING_DEPS=1
check_dep "" "libavcodec" "sudo apt install libavcodec-dev libavformat-dev libavutil-dev libswscale-dev libswresample-dev" || MISSING_DEPS=1

# Qt6 check (multiple possible locations)
QT_FOUND=0
if [ -n "$QT_PREFIX_PATH" ] && [ -d "$QT_PREFIX_PATH" ]; then
    echo "✅ Qt6: $QT_PREFIX_PATH (explicit)"
    QT_FOUND=1
elif command -v qmake6 &> /dev/null; then
    echo "✅ Qt6: found via qmake6"
    QT_FOUND=1
elif [ -d "/usr/lib/qt6" ]; then
    QT_PREFIX_PATH="/usr/lib/qt6"
    echo "✅ Qt6: /usr/lib/qt6"
    QT_FOUND=1
elif [ -d "$HOME/Qt" ]; then
    QT_DIR=$(find "$HOME/Qt" -maxdepth 1 -name "6.*" -type d | sort -V | tail -1)
    if [ -n "$QT_DIR" ]; then
        GCC_DIR=$(find "$QT_DIR" -maxdepth 1 -name "gcc_64" -type d | head -1)
        if [ -n "$GCC_DIR" ]; then
            QT_PREFIX_PATH="$GCC_DIR"
            echo "✅ Qt6: $QT_PREFIX_PATH (user install)"
            QT_FOUND=1
        fi
    fi
fi

if [ "$QT_FOUND" -eq 0 ]; then
    echo "❌ Qt6 not found!"
    echo ""
    echo "Install options:"
    echo "  Ubuntu/Debian: sudo apt install qt6-base-dev qt6-declarative-dev qt6-quickcontrols2-dev qt6-charts-dev"
    echo "  Online installer: https://www.qt.io/download-qt-installer"
    echo ""
    MISSING_DEPS=1
fi

if [ "$MISSING_DEPS" -eq 1 ]; then
    echo ""
    echo "⚠️  Some dependencies are missing. Install them and try again."
    exit 1
fi

# ── Configure ─────────────────────────────────────────────────────────────────

echo ""
echo "📦 Configuring..."

CMAKE_ARGS=(
    -B "$BUILD_DIR"
    -DCMAKE_BUILD_TYPE="$BUILD_TYPE"
)

if [ -n "$QT_PREFIX_PATH" ]; then
    CMAKE_ARGS+=(-DCMAKE_PREFIX_PATH="$QT_PREFIX_PATH")
fi

cmake "${CMAKE_ARGS[@]}"

# ── Build ─────────────────────────────────────────────────────────────────────

echo ""
echo "🔨 Building..."

CPU_CORES=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)
cmake --build "$BUILD_DIR" --parallel "$CPU_CORES"

# ── Done ──────────────────────────────────────────────────────────────────────

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║  ✅ EverFree built successfully!              ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
echo "Run with: $BUILD_DIR/everfree"
echo ""

# Ask if user wants to run
read -p "🚀 Run EverFree now? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    "$BUILD_DIR/everfree"
fi
