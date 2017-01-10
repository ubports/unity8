find_package(Qt5DBus REQUIRED)

include_directories(
    ${CMAKE_SOURCE_DIR}/plugins/Unity/ApplicationMenu
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
)

set(FakeApplicationMenu_SRCS
    ${CMAKE_SOURCE_DIR}/plugins/Unity/ApplicationMenu/applicationmenuregistry.cpp
    mockapplicationmenuregistry.cpp
    plugin.cpp)

add_library(FakeApplicationMenu-qml MODULE ${FakeApplicationMenu_SRCS})

qt5_use_modules(FakeApplicationMenu-qml Qml DBus)

add_unity8_mock(Unity.ApplicationMenu 1.0 Unity/ApplicationMenu PREFIX mocks TARGETS FakeApplicationMenu-qml)
