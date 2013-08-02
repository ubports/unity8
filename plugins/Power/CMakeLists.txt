include(Plugins)

add_definitions(-DSM_BUSNAME=systemBus)

add_library(Power-qml MODULE
    plugin.cpp
    Power.cpp
    )

qt5_use_modules(Power-qml DBus Qml)

export_qmlfiles(Power Power)
export_qmlplugin(Power 0.1 Power TARGETS Power-qml)
