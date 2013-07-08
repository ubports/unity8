# Dependencies
include(FindPkgConfig)
pkg_check_modules(LAUNCHER_API REQUIRED unity-shell-launcher)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
)

set(QMLLAUNCHERPLUGIN_SRC
    plugin.cpp
    launchermodel.cpp
    launcheritem.cpp
    quicklistmodel.cpp
    common/quicklistentry.cpp
    backend/launcherbackend.cpp
    ${LAUNCHER_API_INCLUDEDIR}/unity/shell/launcher/LauncherItemInterface.h
    ${LAUNCHER_API_INCLUDEDIR}/unity/shell/launcher/LauncherModelInterface.h
    ${LAUNCHER_API_INCLUDEDIR}/unity/shell/launcher/QuickListModelInterface.h
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
