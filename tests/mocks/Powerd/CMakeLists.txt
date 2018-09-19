add_definitions(-DSM_BUSNAME=sessionBus)

add_library(MockPowerd-qml MODULE
    plugin.cpp
    Powerd.cpp
    )

target_link_libraries(MockPowerd-qml Qt5::Qml)

add_unity8_mock(Powerd 0.1 Powerd TARGETS MockPowerd-qml)
