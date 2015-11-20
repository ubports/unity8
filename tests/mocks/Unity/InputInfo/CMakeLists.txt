# TODO: This is a copy of the plugin in plugins/Unity/InputInfo which in
# turn is a copy of the WIP upstream InputInfo API. This needs to be updated
# and brought in sync if our snapshot is updated.
# Long term goal is to merge the InputInfo API upstream.

find_package(Qt5Core REQUIRED)
find_package(Qt5Quick REQUIRED)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_SOURCE_DIR}/plugins/Unity/InputInfo/
)

add_definitions(-DUNITY_MOCKS)

set(MockInputInfo_SOURCES
    plugin.cpp
    qinputdeviceinfo_mock.cpp
    mockcontroller.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Unity/InputInfo/qinputinfo.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Unity/InputInfo/qdeclarativeinputdevicemodel.cpp
)

add_library(MockInputInfo SHARED
    ${MockInputInfo_SOURCES}
)

qt5_use_modules(MockInputInfo Core Qml Quick)

add_unity8_mock(Unity.InputInfo 0.1 Unity/InputInfo TARGETS MockInputInfo)
