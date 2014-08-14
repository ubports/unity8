set(MOCK_SYSTEMIMAGE_SOURCES
    plugin.cpp
    MockSystemImage.cpp
)

add_library(MockSystemImage MODULE ${MOCK_SYSTEMIMAGE_SOURCES})

qt5_use_modules(MockSystemImage Qml Quick Core)

add_unity8_mock(Ubuntu.SystemImage 0.1 Ubuntu/SystemImage TARGETS MockSystemImage)
