add_definitions(-DSM_BUSNAME=sessionBus)

add_library(MockPowerd-qml MODULE
    plugin.cpp
    Powerd.cpp
    )

qt5_use_modules(MockPowerd-qml Qml)

add_unity8_mock(Powerd 0.1 Powerd TARGETS MockPowerd-qml)
