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

qt5_use_modules(UnitySession-qml DBus Qml)

# export the qmldir and qmltypes files
add_unity8_plugin(Unity.Session 0.1 Unity/Session TARGETS UnitySession-qml)
