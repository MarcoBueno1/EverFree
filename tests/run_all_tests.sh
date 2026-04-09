#!/bin/bash
# ── EverFree - Run All Tests ───────────────────────────────────────────────────
#
# Usage:
#   ./run_all_tests.sh              # Run all tests
#   ./run_all_tests.sh --unit       # Run only unit tests
#   ./run_all_tests.sh --integration # Run only integration tests
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_DIR/build"

echo "================================================================================"
echo "  EVERFREE - TEST SUITE"
echo "================================================================================"
echo ""

# Build tests if needed
if [ ! -f "$BUILD_DIR/tests/everfree_tests" ]; then
    echo "📦 Building tests..."
    cd "$PROJECT_DIR"
    cmake -B build -DCMAKE_BUILD_TYPE=Release > /dev/null 2>&1
    cmake --build build --target everfree_tests --parallel > /dev/null 2>&1
    echo "✅ Build complete"
    echo ""
fi

RUN_UNIT=false
RUN_INTEGRATION=false

if [ "$1" == "--unit" ]; then
    RUN_UNIT=true
elif [ "$1" == "--integration" ]; then
    RUN_INTEGRATION=true
else
    RUN_UNIT=true
    RUN_INTEGRATION=true
fi

FAILED=0

# Run C++ Unit Tests
if [ "$RUN_UNIT" = true ]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  📝 C++ UNIT TESTS"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    if "$BUILD_DIR/tests/everfree_tests"; then
        echo ""
        echo "✅ Unit tests PASSED"
    else
        echo ""
        echo "❌ Unit tests FAILED"
        FAILED=1
    fi
    echo ""
fi

# Run Integration/Automated Tests
if [ "$RUN_INTEGRATION" = true ]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  🔗 INTEGRATION TESTS"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    if python3 "$SCRIPT_DIR/run_tests.py"; then
        echo ""
        echo "✅ Integration tests PASSED"
    else
        echo ""
        echo "❌ Integration tests FAILED"
        FAILED=1
    fi
    echo ""
fi

# Final Summary
echo "================================================================================"
if [ $FAILED -eq 0 ]; then
    echo "  🎉 ALL TESTS PASSED!"
    echo "================================================================================"
    exit 0
else
    echo "  ⚠️  SOME TESTS FAILED"
    echo "================================================================================"
    exit 1
fi
