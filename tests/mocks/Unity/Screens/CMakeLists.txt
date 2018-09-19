include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
)

set(MockScreens_SOURCES
    plugin.cpp
    screens.cpp
)

add_library(MockScreensPlugin MODULE ${MockScreens_SOURCES})

target_link_libraries(MockScreensPlugin Qt5::Gui Qt5::Qml)

add_unity8_mock(Unity.Screens 0.1 Unity/Screens PREFIX mocks TARGETS MockScreensPlugin)
