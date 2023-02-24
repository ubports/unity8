include_directories(${GLIB_INCLUDE_DIRS})
add_definitions(-DSM_BUSNAME=sessionBus)

add_library(Broadcaster-qml MODULE
    Broadcaster.cpp
    plugin.cpp
    )

qt5_use_modules(Broadcaster-qml DBus Qml)

target_link_libraries(Broadcaster-qml
    ${GLIB_LIBRARIES}
    )

add_unity8_plugin(Broadcaster 0.1 Broadcaster TARGETS Broadcaster-qml)
