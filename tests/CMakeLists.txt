# ── EverFree Tests ──────────────────────────────────────────────────────────────

find_package(Qt6 REQUIRED COMPONENTS Core Gui Test Sql)

# Test executable - only simple unit tests that don't need full app dependencies
add_executable(everfree_tests
    test_fileutils.cpp
)

target_link_libraries(everfree_tests PRIVATE
    batchpress_core
    Qt6::Core
    Qt6::Gui
    Qt6::Test
    Qt6::Sql
)

target_include_directories(everfree_tests PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/../src
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/utils
    ${BATCHPRESS_DIR}/core/include
)

# Register tests
add_test(NAME everfree_unit_tests COMMAND everfree_tests)
