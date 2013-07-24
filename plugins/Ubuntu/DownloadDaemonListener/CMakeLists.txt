include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
    ${Qt5Gui_PRIVATE_INCLUDE_DIRS}
)

set(DOWNLOADDAEMONLISTENER_SOURCES
    backend.cpp
    download_tracker.cpp
    interface/downloadtrackeradaptor.cpp
    )

add_library(DownloadDaemonListener MODULE
    ${DOWNLOADDAEMONLISTENER_SOURCES}
    )
# Because this is an internal support library, we want
# to expose all symbols in it. Consider changing this
# either to a static library or just using the
# files directly in targets.
set_target_properties(DownloadDaemonListener PROPERTIES COMPILE_FLAGS -fvisibility=default)

qt5_use_modules(DownloadDaemonListener Qml Quick DBus Core)

# copy qmldir file into build directory for shadow builds
file(COPY "${CMAKE_CURRENT_SOURCE_DIR}/qmldir"
    DESTINATION ${CMAKE_CURRENT_BINARY_DIR}
    )

install(TARGETS DownloadDaemonListener
    DESTINATION ${SHELL_APP_DIR}/plugins/Ubuntu/DownloadDaemonListener
    )

install(FILES qmldir
    DESTINATION ${SHELL_APP_DIR}/plugins/Ubuntu/DownloadDaemonListener
    )
