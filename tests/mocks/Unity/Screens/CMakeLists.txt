include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
)

set(MockScreens_SOURCES
    plugin.cpp
    screens.cpp
)

add_library(MockScreensPlugin MODULE ${MockScreens_SOURCES})

qt5_use_modules(MockScreensPlugin Gui Qml)

add_unity8_mock(Unity.Screens 0.1 Unity/Screens TARGETS MockScreensPlugin)
