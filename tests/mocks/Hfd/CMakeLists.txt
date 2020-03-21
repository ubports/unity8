add_library(MockHfd-qml MODULE
    plugin.cpp
    Leds.cpp
    )

qt5_use_modules(MockHfd-qml Qml Gui)

add_unity8_mock(Hfd 0.1 Hfd TARGETS MockHfd-qml)
