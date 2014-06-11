cmake_minimum_required(VERSION 2.8.9)

# Default install location. Must be set here, before setting the project.
if (NOT DEFINED CMAKE_INSTALL_PREFIX)
    set(CMAKE_INSTALL_PREFIX ${CMAKE_BINARY_DIR}/install CACHE PATH "" FORCE)
endif()

project(unity8 C CXX)

if(${PROJECT_BINARY_DIR} STREQUAL ${PROJECT_SOURCE_DIR})
   message(FATAL_ERROR "In-tree build attempt detected, aborting. Set your build dir outside your source dir, delete CMakeCache.txt from source root and try again.")
endif()

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules)

# Instruct CMake to run moc automatically when needed.
set(CMAKE_AUTOMOC ON)

# enable QML debugging
string(TOLOWER "${CMAKE_BUILD_TYPE}" cmake_build_type_lower) # Build types should always be lowercase but sometimes they are not.
if(cmake_build_type_lower MATCHES "debug")
    add_definitions(-DQT_QML_DEBUG)
endif()

include(EnableCoverageReport)
#####################################################################
# Enable code coverage calculation with gcov/gcovr/lcov
# Usage:
#  * Switch build type to coverage (use ccmake or cmake-gui)
#  * Invoke make, make test, make coverage (or ninja if you use that backend)
#  * Find html report in subdir coveragereport
#  * Find xml report feasible for jenkins in coverage.xml
#####################################################################
if(cmake_build_type_lower MATCHES coverage)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} --coverage" )
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} --coverage" )
  set(CMAKE_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS} --coverage" )
  set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} --coverage" )
  ENABLE_COVERAGE_REPORT(TARGETS ${SHELL_APP} FILTER /usr/include ${CMAKE_SOURCE_DIR}/tests/* ${CMAKE_BINARY_DIR}/*)
endif()

# Make sure we have all the needed symbols
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,-z,defs")
set(CMAKE_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS} -Wl,-z,defs")

# Static C++ checks
add_custom_target(cppcheck COMMAND cppcheck --enable=all -q --error-exitcode=2
                                       ${CMAKE_SOURCE_DIR}/src ${CMAKE_SOURCE_DIR}/tests)

include(FindPkgConfig)
find_package(Qt5Core 5.2 REQUIRED)
find_package(Qt5Qml 5.2 REQUIRED)
find_package(Qt5Quick 5.2 REQUIRED)
find_package(Qt5Gui 5.2 REQUIRED)
find_package(Qt5DBus 5.2 REQUIRED)

# Standard install paths
include(GNUInstallDirs)

set(SHELL_APP_DIR ${CMAKE_INSTALL_DATADIR}/unity8)

execute_process(COMMAND ${PKG_CONFIG_EXECUTABLE} --variable=plugindir_suffix unity-shell-api OUTPUT_VARIABLE SHELL_INSTALL_QML OUTPUT_STRIP_TRAILING_WHITESPACE)
if(SHELL_INSTALL_QML STREQUAL "")
    message(FATAL_ERROR "Could not determine plugin installation dir.")
endif()

execute_process(COMMAND ${PKG_CONFIG_EXECUTABLE} --variable=plugindir unity-shell-api OUTPUT_VARIABLE SHELL_PLUGINDIR OUTPUT_STRIP_TRAILING_WHITESPACE)
if(SHELL_PLUGINDIR STREQUAL "")
    message(FATAL_ERROR "Could not determine plugin import dir.")
endif()

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fvisibility=hidden")

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -fno-permissive -pedantic -Wall -Wextra")

if ("${CMAKE_BUILD_TYPE}" STREQUAL "release" OR "${CMAKE_BUILD_TYPE}" STREQUAL "relwithdebinfo")
    option(Werror "Treat warnings as errors" ON)
else()
    option(Werror "Treat warnings as errors" OFF)
endif()

if (Werror)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Werror")
endif()

# gtk and unity-core (actually sigc++) do not like Qt defining macros named
# "signals" and "slots"
add_definitions(-DQT_NO_KEYWORDS)

# Tests
include(CTest)
enable_testing()

# Autopilot tests
include(autopilot)
declare_autopilot_test(shell unity8.shell ${CMAKE_SOURCE_DIR}/tests/autopilot/)

set(SHELL_APP unity8)
set(GREETER_APP unity8-greeter)
set(SCOPE_TOOL unity-scope-tool)

include_directories(
    ${CMAKE_SOURCE_DIR}/include
    ${CMAKE_BINARY_DIR}/include
)

# add subdirectories to build
add_subdirectory(include)
add_subdirectory(src)
add_subdirectory(tools)
add_subdirectory(qml)
add_subdirectory(tests)
add_subdirectory(plugins)

#
# Data files
#
add_subdirectory(data)

#
# Translation
#
add_subdirectory(po)

#
# Documentation
#
add_subdirectory(doc)
