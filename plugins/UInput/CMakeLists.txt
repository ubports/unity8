add_library(UInput-qml MODULE
    plugin.cpp
    uinput.cpp
)

target_link_libraries(UInput-qml Qt5::Qml)
add_unity8_plugin(UInput 0.1 UInput TARGETS UInput-qml)
