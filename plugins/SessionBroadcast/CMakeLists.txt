add_definitions(-DSM_BUSNAME=systemBus)

add_library(SessionBroadcast-qml MODULE
    SessionBroadcast.cpp
    plugin.cpp
    )

qt5_use_modules(SessionBroadcast-qml DBus Qml)

add_unity8_plugin(SessionBroadcast 0.1 SessionBroadcast TARGETS SessionBroadcast-qml)
