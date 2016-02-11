include_directories(
    ${GIO_INCLUDE_DIRS}
)

add_definitions(-DSM_BUSNAME=systemBus)

add_library(Powerd-qml MODULE
    plugin.cpp
    Powerd.cpp
    )

qt5_use_modules(Powerd-qml DBus Qml)
target_link_libraries(Powerd-qml ${GIO_LDFLAGS})

add_unity8_plugin(Powerd 0.1 Powerd TARGETS Powerd-qml)
