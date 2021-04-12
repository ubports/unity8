add_library(MockLights-qml MODULE
    plugin.cpp
    Lights.cpp
    )

target_link_libraries(MockLights-qml Qt5::Qml Qt5::Gui)

add_lomiri_mock(Lights 0.1 Lights TARGETS MockLights-qml)
