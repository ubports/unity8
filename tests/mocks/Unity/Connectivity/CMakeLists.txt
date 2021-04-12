set(MOCK_CONNECTIVITY_SOURCES
    plugin.cpp
    MockConnectivity.cpp
)

add_library(MockConnectivity MODULE ${MOCK_CONNECTIVITY_SOURCES})

target_link_libraries(MockConnectivity Qt5::Qml Qt5::Quick Qt5::Core)

add_lomiri_mock(Unity.Connectivity 0.1 Unity/Connectivity TARGETS MockConnectivity)
