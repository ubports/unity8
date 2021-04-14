set(CONNECTIVITY_SOURCES
    plugin.cpp
    ModemConnectivity.cpp
)

add_library(ModemConnectivity MODULE ${CONNECTIVITY_SOURCES})

target_link_libraries(ModemConnectivity Qt5::Qml Qt5::DBus Qt5::Core)

add_lomiri_plugin(Lomiri.ModemConnectivity 0.1 Lomiri/ModemConnectivity TARGETS ModemConnectivity)
