include(FindPkgConfig)
pkg_check_modules(LAUNCHER_API REQUIRED unity-shell-launcher=2)

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

# export the qmldir and qmltypes files
export_qmlplugin(Unity.Launcher 0.1 Unity/Launcher TARGETS UnityLauncher-qml)
