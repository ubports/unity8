include_directories(
    ${GIO_INCLUDE_DIRS}
)

add_definitions(-DSM_BUSNAME=systemBus)

add_library(Powerd-qml MODULE
    plugin.cpp
    Powerd.cpp
    )

target_link_libraries(Powerd-qml
    Qt5::DBus Qt5::Qml
    ${GIO_LDFLAGS}
    )

add_unity8_plugin(Powerd 0.1 Powerd TARGETS Powerd-qml)
