# Dependencies
include(FindPkgConfig)
pkg_check_modules(LIBUNITY_API REQUIRED libunity-api)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
    ${LIBUNITY_API_INCLUDEDIR}
)

message(found ${LIBUNITY_API_INCLUDEDIR})

set(QMLLAUNCHERPLUGIN_SRC
    plugin.cpp
    launchermodel.cpp
    launcheritem.cpp
    ${LIBUNITY_API_INCLUDEDIR}/unity/shell/launcher/LauncherItemInterface.h
    ${LIBUNITY_API_INCLUDEDIR}/unity/shell/launcher/LauncherModelInterface.h
    )

add_library(UnityLauncher-qml MODULE
    ${QMLLAUNCHERPLUGIN_SRC}
    )

qt5_use_modules(UnityLauncher-qml Qml)

# copy qmldir file into build directory for shadow builds
file(COPY "${CMAKE_CURRENT_SOURCE_DIR}/qmldir"
    DESTINATION ${CMAKE_CURRENT_BINARY_DIR}
    )

install(TARGETS UnityLauncher-qml
    DESTINATION ${SHELL_APP_DIR}/plugins/Unity/Launcher/
    )

install(FILES qmldir
    DESTINATION ${SHELL_APP_DIR}/plugins/Unity/Launcher/
    )
