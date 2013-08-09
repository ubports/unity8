# export_qmlplugin macro
include(Plugins)

set(CMAKE_AUTOMOC ON)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
    ${Qt5Gui_PRIVATE_INCLUDE_DIRS}
)

set(DOWNLOADDAEMONLISTENER_SOURCES
    plugin.cpp
    DownloadTracker.cpp
    interface/downloadtrackeradaptor.cpp
    )

add_library(DownloadDaemonListener MODULE ${DOWNLOADDAEMONLISTENER_SOURCES})

qt5_use_modules(DownloadDaemonListener Qml Quick DBus Core)

# export the qmldir qmltypes and plugin files
export_qmlfiles(Ubuntu.DownloadDaemonListener Ubuntu/DownloadDaemonListener)
export_qmlplugin(Ubuntu.DownloadDaemonListener 0.1 Ubuntu/DownloadDaemonListener TARGETS DownloadDaemonListener)
