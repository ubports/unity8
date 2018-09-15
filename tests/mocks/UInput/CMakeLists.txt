add_library(FakeUInput-qml MODULE
    plugin.cpp
    mockuinput.cpp
)

target_link_libraries(FakeUInput-qml Qt5::Qml)
add_unity8_mock(UInput 0.1 UInput TARGETS FakeUInput-qml)
