set(globalshortcutplugin_SRCS
    globalshortcut.cpp
    globalshortcutregistry.cpp
    plugin.cpp)

add_library(GlobalShortcut-qml SHARED ${globalshortcutplugin_SRCS})

qt5_use_modules(GlobalShortcut-qml Quick Gui)

add_unity8_plugin(GlobalShortcut 1.0 GlobalShortcut TARGETS GlobalShortcut-qml)
