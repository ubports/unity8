include(Plugins)
include(FindPkgConfig)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
)

set(QMLSESSIONPLUGIN_SRC
    plugin.cpp
    dbusunitysessionservice.cpp
    )

add_library(UnitySession-qml MODULE
    ${QMLSESSIONPLUGIN_SRC}
    )

target_link_libraries(UnitySession-qml)

qt5_use_modules(UnitySession-qml DBus Qml)

# export the qmldir and qmltypes files
export_qmlfiles(Unity.Session Unity/Session)
export_qmlplugin(Unity.Session 0.1 Unity/Session TARGETS UnitySession-qml)
