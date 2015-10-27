set(platformplugin_SRCS
    platform.cpp
    plugin.cpp)

add_library(Platform-qml SHARED ${platformplugin_SRCS})

qt5_use_modules(Platform-qml DBus Qml)

add_unity8_plugin(Unity.Platform 1.0 Unity/Platform TARGETS Platform-qml)
