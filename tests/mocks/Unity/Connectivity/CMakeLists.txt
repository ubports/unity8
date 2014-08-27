set(MOCK_CONNECTIVITY_SOURCES
    plugin.cpp
    MockConnectivity.cpp
)

add_library(MockConnectivity MODULE ${MOCK_CONNECTIVITY_SOURCES})

qt5_use_modules(MockConnectivity Qml Quick Core)

add_unity8_mock(Unity.Connectivity 0.1 Unity/Connectivity TARGETS MockConnectivity)
