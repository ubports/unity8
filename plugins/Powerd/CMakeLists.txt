include(Plugins)
include(FindPkgConfig)

pkg_search_module(GIO REQUIRED gio-2.0)

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

export_qmlfiles(Powerd Powerd)
export_qmlplugin(Powerd 0.1 Powerd TARGETS Powerd-qml)
