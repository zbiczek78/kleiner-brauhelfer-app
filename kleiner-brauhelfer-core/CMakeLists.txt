cmake_minimum_required(VERSION 3.16)

# Project metadata
set(ORGANIZATION kleiner-brauhelfer)
set(TARGET kleiner-brauhelfer-core)
set(VERSION 2.9.8)
set(BUILD_TYPE STATIC)

project(${TARGET} VERSION ${VERSION} LANGUAGES CXX)

# --------------------------
# Qt6 configuration
# --------------------------
# Pozwala nadpisać Qt6_DIR z workflow
if(NOT Qt6_DIR)
    set(Qt6_DIR "$ENV{Qt6_DIR}")
endif()

find_package(Qt6 REQUIRED COMPONENTS Core Sql Xml)

# Standard project setup
qt_standard_project_setup(REQUIRES 6.5)

# Optional: static linking (OFF by default)
set(Qt6_STATIC OFF CACHE BOOL "" FORCE)

# --------------------------
# C++ settings
# --------------------------
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Multi-ABI support for Android
set(QT_ANDROID_BUILD_ALL_ABIS TRUE)

# --------------------------
# Sources and headers
# --------------------------
file(GLOB SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/*.cpp")
file(GLOB HEADERS "${CMAKE_CURRENT_SOURCE_DIR}/*.h")

# --------------------------
# Library target
# --------------------------
qt_add_library(${PROJECT_NAME} ${BUILD_TYPE}
    ${SOURCES}
    ${HEADERS}
)

target_include_directories(${PROJECT_NAME} PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})

# Definitions
target_compile_definitions(${PROJECT_NAME} PRIVATE
    ORGANIZATION="${ORGANIZATION}"
    TARGET="${TARGET}"
    VER_MAJ=${PROJECT_VERSION_MAJOR}
    VER_MIN=${PROJECT_VERSION_MINOR}
    VER_PAT=${PROJECT_VERSION_PATCH}
    VERSION="${PROJECT_VERSION}"
)

# Static/shared build type
if(${BUILD_TYPE} STREQUAL STATIC)
    target_compile_definitions(${PROJECT_NAME} PRIVATE KLEINERBRAUHELFERCORE_LIBRARY_STATIC)
elseif(${BUILD_TYPE} STREQUAL SHARED)
    target_compile_definitions(${PROJECT_NAME} PRIVATE KLEINERBRAUHELFERCORE_LIBRARY_SHARED)
else()
    message(FATAL_ERROR "BUILD_TYPE must be either STATIC or SHARED")
endif()

# --------------------------
# Link Qt libraries
# --------------------------
target_link_libraries(${PROJECT_NAME} PRIVATE
    Qt6::Core
    Qt6::Sql
    Qt6::Xml
)

# --------------------------
# Android-specific
# --------------------------
if(ANDROID)
    message(STATUS "Building for Android: enabling multi-ABI")
    set(QT_ANDROID_BUILD_ALL_ABIS TRUE)
endif()
