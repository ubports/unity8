include(Plugins)

add_definitions(-DSM_BUSNAME=systemBus)

add_library(Powerd-qml MODULE
    plugin.cpp
    Powerd.cpp
    )

qt5_use_modules(Powerd-qml DBus Qml)

export_qmlfiles(Powerd Powerd)
export_qmlplugin(Powerd 0.1 Powerd TARGETS Powerd-qml)
