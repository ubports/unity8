# TODO: This is a copy of the plugin in plugins/Lomiri/InputInfo which in
# turn is a copy of the WIP upstream InputInfo API. This needs to be updated
# and brought in sync if our snapshot is updated.
# Long term goal is to merge the InputInfo API upstream.

find_package(Qt5Core REQUIRED)
find_package(Qt5Quick REQUIRED)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_SOURCE_DIR}/plugins/Lomiri/InputInfo/
)

add_definitions(-DLOMIRI_MOCKS)

set(MockInputInfo_SOURCES
    plugin.cpp
    qinputdeviceinfo_mock.cpp
    mockcontroller.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Lomiri/InputInfo/qinputinfo.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Lomiri/InputInfo/qdeclarativeinputdevicemodel.cpp
)

add_library(MockInputInfo SHARED
    ${MockInputInfo_SOURCES}
)

target_link_libraries(MockInputInfo Qt5::Core Qt5::Qml Qt5::Quick)

add_lomiri_mock(Lomiri.InputInfo 0.1 Lomiri/InputInfo TARGETS MockInputInfo)
