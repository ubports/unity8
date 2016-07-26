include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
    ${GIO_INCLUDE_DIRS}
    ${GLIB_INCLUDE_DIRS}
    ${libunity8-private_SOURCE_DIR}
)

add_definitions(-DSM_BUSNAME=systemBus)

set(QMLSESSIONPLUGIN_SRC
    plugin.cpp
    dbusunitysessionservice.cpp
    orientationlock.cpp
    )

add_library(UnitySession-qml MODULE
    ${QMLSESSIONPLUGIN_SRC}
    )

qt5_use_modules(UnitySession-qml DBus Qml)
target_link_libraries(UnitySession-qml
    unity8-private
    ${GIO_LDFLAGS}
    ${GLIB_LIBRARIES}
    )

# export the qmldir and qmltypes files
add_unity8_plugin(Unity.Session 0.1 Unity/Session TARGETS UnitySession-qml)
