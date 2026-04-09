# ── EverFree — Modern Desktop GUI for batchpress ──────────────────────────────
#
# A beautiful, dual-mode desktop application that gives users
# complete control over their disk space — powered by batchpress core.
#
# Build:
#   cmake -B build -DCMAKE_PREFIX_PATH=/path/to/Qt6 -DCMAKE_BUILD_TYPE=Release
#   cmake --build build --parallel
#
# Requires:
#   - Qt6 (Core, Gui, Qml, Quick, QuickControls2, Charts)
#   - FFmpeg dev libraries
#   - libwebp dev (optional, for WebP)
#   - batchpress source tree (linked directly)

cmake_minimum_required(VERSION 3.16)
project(EverFree VERSION 1.0.0 LANGUAGES CXX)

# ── Standards ──────────────────────────────────────────────────────────────────
set(CMAKE_CXX_STANDARD          17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS        OFF)
set(CMAKE_AUTOMOC ON)

# ── Compiler flags ─────────────────────────────────────────────────────────────
if(MSVC)
    add_compile_options(/W4 /O2 /utf-8)
else()
    add_compile_options(-Wall -Wextra -Wpedantic -O2)
    if(NOT ANDROID)
        add_compile_options(-pthread)
        add_link_options(-pthread)
    endif()
endif()

# ── BatchPress Core path ───────────────────────────────────────────────────────
# Point this to your batchpress checkout
set(BATCHPRESS_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../GitHub/batchpress"
    CACHE PATH "Path to batchpress repository")

if(NOT EXISTS "${BATCHPRESS_DIR}/core/include/batchpress/types.hpp")
    message(FATAL_ERROR
        "batchpress not found at ${BATCHPRESS_DIR}\n"
        "Set BATCHPRESS_DIR to your batchpress checkout:\n"
        "  cmake -B build -DBATCHPRESS_DIR=/path/to/batchpress"
    )
endif()

message(STATUS "BatchPress core: ${BATCHPRESS_DIR}")

# ── Find Qt6 ───────────────────────────────────────────────────────────────────
find_package(Qt6 REQUIRED COMPONENTS
    Core Gui Widgets Qml Quick QuickControls2 Charts Sql
)

qt_standard_project_setup(REQUIRES 6.5)

# ── Include batchpress core sources directly ───────────────────────────────────

# stb headers
set(STB_DIR "${BATCHPRESS_DIR}/core/third_party")
function(ensure_stb_header FILENAME URL)
    set(DEST "${STB_DIR}/${FILENAME}")
    if(NOT EXISTS "${DEST}")
        file(DOWNLOAD "${URL}" "${DEST}" STATUS DL_STATUS TLS_VERIFY ON)
        list(GET DL_STATUS 0 DL_CODE)
        if(NOT DL_CODE EQUAL 0)
            message(FATAL_ERROR "Failed to download ${FILENAME}")
        endif()
    endif()
endfunction()
set(STB_RAW "https://raw.githubusercontent.com/nothings/stb/master")
ensure_stb_header(stb_image.h        "${STB_RAW}/stb_image.h")
ensure_stb_header(stb_image_write.h  "${STB_RAW}/stb_image_write.h")
ensure_stb_header(stb_image_resize2.h "${STB_RAW}/stb_image_resize2.h")

# Core library (built from batchpress sources)
set(CORE_SOURCES
    ${BATCHPRESS_DIR}/core/src/types.cpp
    ${BATCHPRESS_DIR}/core/src/processor.cpp
    ${BATCHPRESS_DIR}/core/src/scanner.cpp
)

# Video support
find_package(PkgConfig QUIET)
if(PkgConfig_FOUND)
    pkg_check_modules(FFMPEG QUIET
        libavcodec libavformat libavutil libswscale libswresample)
    if(FFMPEG_FOUND)
        list(APPEND CORE_SOURCES ${BATCHPRESS_DIR}/core/src/video_processor.cpp)
        add_compile_definitions(BATCHPRESS_HAS_VIDEO)
    endif()

    pkg_check_modules(WEBP QUIET libwebp)
    if(WEBP_FOUND)
        add_compile_definitions(BATCHPRESS_HAS_WEBP)
    endif()
endif()

add_library(batchpress_core STATIC ${CORE_SOURCES})
target_include_directories(batchpress_core
    PUBLIC ${BATCHPRESS_DIR}/core/include
    PRIVATE ${STB_DIR}
)
if(FFMPEG_FOUND)
    target_include_directories(batchpress_core PRIVATE ${FFMPEG_INCLUDE_DIRS})
    target_link_libraries(batchpress_core PRIVATE ${FFMPEG_LIBRARIES})
endif()
if(WEBP_FOUND)
    target_include_directories(batchpress_core PRIVATE ${WEBP_INCLUDE_DIRS})
    target_link_libraries(batchpress_core PRIVATE ${WEBP_LIBRARIES})
endif()

# ── EverFree sources ──────────────────────────────────────────────────────────

set(EVERFREE_SOURCES
    src/main.cpp
    src/AppController.cpp
    src/SimpleMode.cpp
    src/AdvancedMode.cpp
    src/cloud/LicenseManager.cpp
    src/cloud/LocalCloudProvider.cpp
    src/db/ProcessingDatabase.cpp
    src/workers/ScanWorker.cpp
    src/workers/ProcessWorker.cpp
    src/workers/VideoProcessWorker.cpp
    src/models/FileItemModel.cpp
    src/models/ScanReportModel.cpp
    src/models/ProgressModel.cpp
    src/utils/FileUtils.cpp
    src/utils/ThemeManager.cpp
)

set(EVERFREE_HEADERS
    src/AppController.hpp
    src/SimpleMode.hpp
    src/AdvancedMode.hpp
    src/cloud/CloudProvider.hpp
    src/cloud/LicenseManager.hpp
    src/cloud/LocalCloudProvider.hpp
    src/db/ProcessingDatabase.hpp
    src/workers/ScanWorker.hpp
    src/workers/ProcessWorker.hpp
    src/workers/VideoProcessWorker.hpp
    src/models/FileItemModel.hpp
    src/models/ScanReportModel.hpp
    src/models/ProgressModel.hpp
    src/utils/FileUtils.hpp
    src/utils/ThemeManager.hpp
)

# QML files
set(QML_FILES
    qml/main.qml
    qml/pages/HomeModePicker.qml
    qml/pages/SimpleWelcome.qml
    qml/pages/AdvancedWelcome.qml
    qml/pages/ScanPage.qml
    qml/pages/SelectPage.qml
    qml/pages/ProcessPage.qml
    qml/pages/ReportPage.qml
    qml/pages/RollbackPage.qml
    qml/components/SavingsBadge.qml
    qml/components/CodecBadge.qml
    qml/components/QualityStars.qml
    qml/components/FileListItem.qml
    qml/components/StatusBar.qml
    qml/components/SavingsChart.qml
    qml/components/FolderCard.qml
    qml/components/BigButton.qml
    qml/dialogs/SettingsDialog.qml
    qml/dialogs/ErrorReportDialog.qml
    qml/dialogs/ConfirmDialog.qml
    qml/dialogs/SubscriptionDialog.qml
)

# ── Executable ─────────────────────────────────────────────────────────────────

qt_add_executable(everfree
    ${EVERFREE_SOURCES}
    ${EVERFREE_HEADERS}
    resources/resources.qrc
)

target_include_directories(everfree PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${CMAKE_CURRENT_SOURCE_DIR}/src/workers
    ${CMAKE_CURRENT_SOURCE_DIR}/src/models
    ${CMAKE_CURRENT_SOURCE_DIR}/src/utils
    ${CMAKE_CURRENT_SOURCE_DIR}/src/cloud
    ${CMAKE_CURRENT_SOURCE_DIR}/src/db
    ${BATCHPRESS_DIR}/core/include
)

target_link_libraries(everfree PRIVATE
    batchpress_core
    Qt6::Core
    Qt6::Gui
    Qt6::Widgets
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Charts
    Qt6::Sql
)

if(FFMPEG_FOUND)
    target_link_libraries(everfree PRIVATE ${FFMPEG_LIBRARIES})
endif()

# QML module
qt_policy(SET QTP0001 NEW)
qt_add_qml_module(everfree
    URI EverFree
    VERSION 1.0
    QML_FILES ${QML_FILES}
    NO_PLUGIN
)

# Suppress warnings from stb headers
foreach(STB_FILE
    ${BATCHPRESS_DIR}/core/src/processor.cpp
    ${BATCHPRESS_DIR}/core/src/scanner.cpp
)
    if(EXISTS ${STB_FILE})
        set_source_files_properties(${STB_FILE} PROPERTIES
            COMPILE_OPTIONS
                "-Wno-unused-but-set-variable;-Wno-missing-field-initializers;-Wno-unused-function"
        )
    endif()
endforeach()

# ── Install ────────────────────────────────────────────────────────────────────
install(TARGETS everfree RUNTIME DESTINATION bin)

# ── Tests ──────────────────────────────────────────────────────────────────────
enable_testing()
add_subdirectory(tests)

message(STATUS "")
message(STATUS "╔══════════════════════════════════════════════╗")
message(STATUS "║  EverFree ${PROJECT_VERSION} configured successfully!  ║")
message(STATUS "╚══════════════════════════════════════════════╝")
message(STATUS "")
