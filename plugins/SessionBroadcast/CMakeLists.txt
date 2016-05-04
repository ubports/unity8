include_directories(${GLIB_INCLUDE_DIRS})
add_definitions(-DSM_BUSNAME=systemBus)

add_library(SessionBroadcast-qml MODULE
    SessionBroadcast.cpp
    plugin.cpp
    )

qt5_use_modules(SessionBroadcast-qml DBus Qml)

target_link_libraries(SessionBroadcast-qml
    ${GLIB_LIBRARIES}
    )

add_unity8_plugin(SessionBroadcast 0.1 SessionBroadcast TARGETS SessionBroadcast-qml)
