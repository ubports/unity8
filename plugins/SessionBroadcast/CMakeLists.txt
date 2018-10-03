include_directories(${GLIB_INCLUDE_DIRS})
add_definitions(-DSM_BUSNAME=systemBus)

add_library(SessionBroadcast-qml MODULE
    SessionBroadcast.cpp
    plugin.cpp
    )

target_link_libraries(SessionBroadcast-qml
    Qt5::DBus Qt5::Qml
    ${GLIB_LIBRARIES}
    )

add_unity8_plugin(SessionBroadcast 0.1 SessionBroadcast TARGETS SessionBroadcast-qml)
