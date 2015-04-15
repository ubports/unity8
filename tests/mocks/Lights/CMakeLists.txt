add_library(MockLights-qml MODULE
    plugin.cpp
    Lights.cpp
    )

qt5_use_modules(MockLights-qml Qml Gui)

add_unity8_mock(Lights 0.1 Lights TARGETS MockLights-qml)
