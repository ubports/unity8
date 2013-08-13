set(FakeUbuntuDownloadDaemonListenerQml_SOURCES
    plugin.cpp
    MockDownloadTracker.cpp
)

add_library(FakeUbuntuDownloadDaemonListenerQml MODULE ${FakeUbuntuDownloadDaemonListenerQml_SOURCES})

qt5_use_modules(FakeUbuntuDownloadDaemonListenerQml Core Quick)

# copy files into build directory for shadow builds
add_custom_target(UbuntuDownloadQmlDirFile ALL
    COMMAND cp "${CMAKE_CURRENT_SOURCE_DIR}/qmldir" ${CMAKE_CURRENT_BINARY_DIR}
    DEPENDS qmldir
)

install(TARGETS FakeUbuntuDownloadDaemonListenerQml
    DESTINATION ${SHELL_PRIVATE_LIBDIR}/qml/mocks/Ubuntu/DownloadDaemonListener
    )
