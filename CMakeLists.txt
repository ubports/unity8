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
find_package(Qt5Core)
find_package(Qt5Qml)
find_package(Qt5Quick)
find_package(Qt5Gui)
find_package(Qt5DBus)

# Standard install paths
include(GNUInstallDirs)

set(SHELL_APP_DIR ${CMAKE_INSTALL_DATADIR}/unity8)
set(SHELL_PRIVATE_LIBDIR ${CMAKE_INSTALL_LIBDIR}/unity8)

configure_file(paths.h.in ${CMAKE_CURRENT_BINARY_DIR}/paths.h @ONLY)

pkg_check_modules(UNITY-MIR REQUIRED unity-mir)

include_directories(
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${Qt5Gui_PRIVATE_INCLUDE_DIRS}
    ${UNITY-MIR_INCLUDE_DIRS}
    )

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

set(shell_app_HDRS
    )

add_executable(${SHELL_APP}
    ${shellapplication_MOC_SRCS}
    ApplicationArguments.h
    main.cpp
    MouseTouchAdaptor.cpp
    )
add_executable(${GREETER_APP}
    ${greeterapplication_MOC_SRCS}
    ApplicationArguments.h
    main.cpp
    MouseTouchAdaptor.cpp
    )

set_target_properties(${SHELL_APP} PROPERTIES
    COMPILE_DEFINITIONS "APP_NAME=\"Unity 8\";QML_FILE=\"Shell.qml\""
    )
set_target_properties(${GREETER_APP} PROPERTIES
    COMPILE_DEFINITIONS "APP_NAME=\"Unity 8 Greeter\";QML_FILE=\"GreeterShell.qml\""
    )

qt5_use_modules(${SHELL_APP} Qml Quick Test)
qt5_use_modules(${GREETER_APP} Qml Quick Test)
pkg_check_modules(XCB REQUIRED xcb)

if (NOT "${XCB_INCLUDE_DIRS}" STREQUAL "")
    set_target_properties(${SHELL_APP} PROPERTIES INCLUDE_DIRECTORIES ${XCB_INCLUDE_DIRS})
endif()

target_link_libraries(${SHELL_APP}
    ${Qt5Qml_LIBRARIES}
    ${Qt5Quick_LIBRARIES}
    ${XCB_LDFLAGS}
    ${CMAKE_DL_LIBS}
    )
target_link_libraries(${GREETER_APP}
    ${Qt5Qml_LIBRARIES}
    ${Qt5Quick_LIBRARIES}
    ${XCB_LDFLAGS}
    )

# install binaries
install(TARGETS ${SHELL_APP} ${GREETER_APP}
     RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
     )

# install top level qml and js files
file(GLOB QML_JS_FILES *.qml *.js)

install(FILES ${QML_JS_FILES}
    DESTINATION ${SHELL_APP_DIR}
    )

# add subdirectories to build
add_subdirectory(tests)
add_subdirectory(plugins)
add_subdirectory(src)

# install subdirectories
set(QML_DIRS
    Applications
    Bottombar
    Components
    Dash
    graphics
    Greeter
    Hud
    Panel
    Launcher
    SideStage
    Notifications
    )

install(DIRECTORY ${QML_DIRS}
    DESTINATION ${SHELL_APP_DIR}
    )

# generate desktop file
configure_file(${SHELL_APP}.desktop.in ${CMAKE_CURRENT_BINARY_DIR}/${SHELL_APP}.desktop @ONLY)
configure_file(${GREETER_APP}.desktop.in ${CMAKE_CURRENT_BINARY_DIR}/${GREETER_APP}.desktop @ONLY)

# install desktop file
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${SHELL_APP}.desktop
    DESTINATION ${CMAKE_INSTALL_DATADIR}/applications
    )
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${GREETER_APP}.desktop
    DESTINATION ${CMAKE_INSTALL_DATADIR}/lightdm/greeters
    )
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/51-${GREETER_APP}.conf
    DESTINATION ${CMAKE_INSTALL_SYSCONFDIR}/lightdm/lightdm.conf.d
    )

#
# Translation
#
add_subdirectory(po)
