add_library(UInput-qml MODULE
    plugin.cpp
    uinput.cpp
)

qt5_use_modules(UInput-qml Qml)
add_unity8_plugin(UInput 0.1 UInput TARGETS UInput-qml)
