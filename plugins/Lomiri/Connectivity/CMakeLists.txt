set(CONNECTIVITY_SOURCES
    plugin.cpp
    Connectivity.cpp
)

add_library(Connectivity MODULE ${CONNECTIVITY_SOURCES})

target_link_libraries(Connectivity Qt5::Qml Qt5::DBus Qt5::Core)

add_lomiri_plugin(Lomiri.Connectivity 0.1 Lomiri/Connectivity TARGETS Connectivity)
