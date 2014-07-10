set(FakeUbuntuTelephonyQml_SOURCES
    plugin.cpp
    ContactWatcherData.cpp
    MockCallEntry.cpp
    MockCallManager.cpp
    MockContactWatcher.cpp
    MockTelepathyHelper.cpp
)

add_library(FakeUbuntuTelephonyQml MODULE ${FakeUbuntuTelephonyQml_SOURCES})

qt5_use_modules(FakeUbuntuTelephonyQml Core Quick)

# copy files into build directory for shadow builds
add_custom_target(UbuntuTelephonyQmlDirFile ALL
    COMMAND cp "${CMAKE_CURRENT_SOURCE_DIR}/qmldir" ${CMAKE_CURRENT_BINARY_DIR}
    DEPENDS qmldir
)

install(TARGETS FakeUbuntuTelephonyQml
    DESTINATION ${SHELL_INSTALL_QML}/mocks/Ubuntu/Telephony
    )
