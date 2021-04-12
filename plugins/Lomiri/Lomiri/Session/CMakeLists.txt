include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
    ${GIO_INCLUDE_DIRS}
    ${GLIB_INCLUDE_DIRS}
    ${liblomiri-private_SOURCE_DIR}
)

add_definitions(-DSM_BUSNAME=systemBus)

set(QMLSESSIONPLUGIN_SRC
    plugin.cpp
    dbuslomirisessionservice.cpp
    orientationlock.cpp
    )

add_library(LomiriSession-qml MODULE
    ${QMLSESSIONPLUGIN_SRC}
    )

target_link_libraries(LomiriSession-qml
    Qt5::DBus Qt5::Qml
    lomiri-private
    ${GIO_LDFLAGS}
    ${GLIB_LIBRARIES}
    )

# export the qmldir and qmltypes files
add_lomiri_plugin(Lomiri.Session 0.1 Lomiri/Session TARGETS LomiriSession-qml)
