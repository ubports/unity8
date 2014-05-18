set(QMLPLUGIN_SRC
    plugin.cpp
    SessionManager.cpp
    )

include_directories(
    ${Qt5DBus_INCLUDE_DIRS}
    )

add_definitions(-DSM_BUSNAME=systemBus)

add_library(SessionManager-qml MODULE
    ${QMLPLUGIN_SRC}
    )

target_link_libraries(SessionManager-qml
    ${Qt5DBus_LIBRARIES}
    )

qt5_use_modules(SessionManager-qml Qml)

add_unity8_plugin(SessionManager 0.1 SessionManager TARGETS SessionManager-qml)
