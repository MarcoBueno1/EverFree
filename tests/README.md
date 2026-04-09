# EverFree - Test Suite

## Overview

This directory contains automated tests for the EverFree application.

## Test Types

### 1. C++ Unit Tests (`everfree_tests`)
- Built with Qt Test framework
- Tests core utility functions
- Fast execution (< 1 second)

**Current coverage:**
- ✅ `batchpress::gui::formatBytes()` - Human-readable file sizes
- ✅ `batchpress::gui::formatDuration()` - Human-readable durations
- 🚧 `AppController` - Main application flows (WIP)
- 🚧 `ScanWorker` - Background scanning (WIP)

### 2. Integration Tests (`run_tests.py`)
- Python script that validates the entire application
- Tests binary existence, QML files, code fixes
- Simulates basic application behavior

**Current coverage:**
- ✅ Binary compilation and execution
- ✅ QML file structure validation
- ✅ Code fix verification (cloud login, cancel safety, validation)
- ✅ Build system integrity

## Running Tests

### Quick Run (All Tests)
```bash
./tests/run_all_tests.sh
```

### Run Only Unit Tests
```bash
./tests/run_all_tests.sh --unit
```

### Run Only Integration Tests
```bash
./tests/run_all_tests.sh --integration
```

### Direct C++ Test Execution
```bash
./build/tests/everfree_tests
```

### Direct Python Test Execution
```bash
python3 tests/run_tests.py
```

## Test Results

### Latest Run (2026-04-09)

**C++ Unit Tests:**
```
Totals: 5 passed, 0 failed, 0 skipped
```

**Integration Tests:**
```
Total: 10 | ✅ 10 | ❌ 0
🎉 ALL TESTS PASSED!
```

## Adding New Tests

### C++ Unit Tests

Create a new test file in `tests/`:

```cpp
#include <QtTest/QtTest>
#include "YourClass.hpp"

class TestYourClass : public QObject
{
    Q_OBJECT

private slots:
    void testSomething();
};

void TestYourClass::testSomething()
{
    // Your test code
    QVERIFY(true);
}

QTEST_MAIN(TestYourClass)
#include "test_yourclass.moc"
```

Then add it to `tests/CMakeLists.txt`.

### Python Integration Tests

Add a new test function in `run_tests.py`:

```python
def test_your_feature():
    """Test description"""
    # Your test code
    if condition:
        results.add_pass("Test name")
    else:
        results.add_fail("Test name", "Reason")
```

Then call it in the main test section.

## CI/CD Integration

To add to GitHub Actions or other CI systems:

```yaml
- name: Build
  run: |
    cmake -B build -DCMAKE_BUILD_TYPE=Release
    cmake --build build --parallel

- name: Test
  run: ./tests/run_all_tests.sh
```

## Coverage Goals

- [ ] 50% unit test coverage by end of Q2 2026
- [ ] All critical paths tested (AppController, Workers)
- [ ] GUI automation tests with pytest-qt
- [ ] Performance regression tests
