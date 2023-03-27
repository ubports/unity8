add_definitions(-DSM_BUSNAME=sessionBus)

add_library(ProcessControl-qml MODULE
    LocationWatcher.cpp
    ProcessControl.cpp
    plugin.cpp
)

target_link_libraries(ProcessControl-qml
    Qt5::DBus Qt5::Qml
)

target_include_directories(ProcessControl-qml PRIVATE ${CMAKE_CURRENT_BINARY_DIR})

add_unity8_plugin(ProcessControl 0.1 ProcessControl TARGETS ProcessControl-qml)

set(DBUS_IFACE_DIR "${CMAKE_INSTALL_PREFIX}/share/dbus-1/interfaces")

install(FILES com.lomiri.ProcessControl.xml
    DESTINATION "${DBUS_IFACE_DIR}"
)
