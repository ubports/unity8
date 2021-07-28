find_package(Qt5DBus REQUIRED)

set(platformplugin_SRCS
    platform.cpp
    plugin.cpp)

add_library(Platform-qml SHARED ${platformplugin_SRCS})

target_link_libraries(Platform-qml Qt5::DBus Qt5::Qml)

add_lomiri_plugin(Lomiri.Platform 1.0 Lomiri/Platform TARGETS Platform-qml)
