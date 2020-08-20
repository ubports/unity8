include_directories(${GLIB_INCLUDE_DIRS})
add_definitions(-DSM_BUSNAME=sessionBus)

add_library(HandleMediaKeys-qml MODULE
    HandleMediaKeys.cpp
    plugin.cpp
    )

qt5_use_modules(HandleMediaKeys-qml DBus Qml)

target_link_libraries(HandleMediaKeys-qml
    ${GLIB_LIBRARIES}
    )

add_unity8_plugin(HandleMediaKeys 0.1 HandleMediaKeys TARGETS HandleMediaKeys-qml)
