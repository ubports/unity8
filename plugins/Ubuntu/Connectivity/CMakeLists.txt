set(CONNECTIVITY_SOURCES
    plugin.cpp
    Connectivity.cpp
)

add_library(Connectivity MODULE ${CONNECTIVITY_SOURCES})

qt5_use_modules(Connectivity Qml DBus Core)

add_unity8_plugin(Ubuntu.Connectivity 0.1 Ubuntu/Connectivity TARGETS Connectivity)
