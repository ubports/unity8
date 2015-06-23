find_package(Qt5Core REQUIRED)
find_package(Qt5Quick REQUIRED)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
)

set(MockInputInfo_SOURCES
    plugin.cpp
    mockqinputinfo.cpp
    mockqdeclarativeinputdeviceinfo.cpp
)

add_library(MockInputInfo SHARED
    ${MockInputInfo_SOURCES}
)

qt5_use_modules(MockInputInfo Core Qml Quick)

add_unity8_mock(Unity.InputInfo 0.1 Unity/InputInfo TARGETS MockInputInfo)
