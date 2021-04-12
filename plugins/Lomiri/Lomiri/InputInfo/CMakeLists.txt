# This is a temporary snapshot of the WIP QInputInfo API as we
# require this in lomiri now but upstream isn't finished yet.
# Eventually this should be dropped in favor of the upstream
# QInputInfo API.

project(InputInfo)

find_package(Qt5Core REQUIRED)
find_package(Qt5Quick REQUIRED)

pkg_check_modules(LIBUDEV REQUIRED libudev)
pkg_check_modules(LIBEVDEV REQUIRED libevdev)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
    ${LIBUDEV_INCLUDE_DIRS}
    ${LIBEVDEV_INCLUDE_DIRS}
)

set(InputInfo_SOURCES
    plugin.cpp
    qinputinfo.cpp
    qdeclarativeinputdevicemodel.cpp
    linux/qinputdeviceinfo_linux.cpp
)

add_library(InputInfo SHARED
    ${InputInfo_SOURCES}
)

target_link_libraries(InputInfo
    ${LIBUDEV_LDFLAGS}
    ${LIBEVDEV_LDFLAGS}
    Qt5::Core Qt5::Qml Qt5::Quick
)

add_lomiri_plugin(Lomiri.InputInfo 0.1 Lomiri/InputInfo TARGETS InputInfo)
