include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
)

set(DOWNLOADDAEMONLISTENER_SOURCES
    plugin.cpp
    DownloadTracker.cpp
    interface/downloadtrackeradaptor.cpp
    )

add_library(DownloadDaemonListener MODULE ${DOWNLOADDAEMONLISTENER_SOURCES})

pkg_check_modules(DDLADAPTER REQUIRED ldm-common)
add_definitions(${DDLADAPTER_CFLAGS} ${DDLADAPTER_CFLAGS_OTHER})
target_link_libraries(DownloadDaemonListener
    Qt5::Qml Qt5::Quick Qt5::DBus Qt5::Core
    ${DDLADAPTER_LIBRARIES}
    )
add_unity8_plugin(Ubuntu.DownloadDaemonListener 0.1 Ubuntu/DownloadDaemonListener TARGETS DownloadDaemonListener)
