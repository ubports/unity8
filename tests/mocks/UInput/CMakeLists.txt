add_library(FakeUInput-qml MODULE
    plugin.cpp
    mockuinput.cpp
)

qt5_use_modules(FakeUInput-qml Qml)
add_unity8_mock(UInput 0.1 UInput TARGETS FakeUInput-qml)
