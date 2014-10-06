include(FindPkgConfig)
pkg_check_modules(LAUNCHER_API REQUIRED unity-shell-launcher=5)
pkg_check_modules(APPLICATION_API REQUIRED unity-shell-application=4)
pkg_check_modules(GSETTINGS_QT REQUIRED gsettings-qt)

add_definitions(-DSM_BUSNAME=systemBus)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_SOURCE_DIR}/plugins/AccountsService
    ${GSETTINGS_QT_INCLUDE_DIRS}
)

set(QMLLAUNCHERPLUGIN_SRC
    plugin.cpp
    launchermodel.cpp
    launcheritem.cpp
    quicklistmodel.cpp
    quicklistentry.cpp
    dbusinterface.cpp
    gsettings.cpp
    desktopfilehandler.cpp
    ${CMAKE_SOURCE_DIR}/plugins/AccountsService/AccountsServiceDBusAdaptor.cpp
    ${LAUNCHER_API_INCLUDEDIR}/unity/shell/launcher/LauncherItemInterface.h
    ${LAUNCHER_API_INCLUDEDIR}/unity/shell/launcher/LauncherModelInterface.h
    ${LAUNCHER_API_INCLUDEDIR}/unity/shell/launcher/QuickListModelInterface.h
    )

add_library(UnityLauncher-qml MODULE
    ${QMLLAUNCHERPLUGIN_SRC}
    )

target_link_libraries(UnityLauncher-qml ${GSETTINGS_QT_LDFLAGS})

qt5_use_modules(UnityLauncher-qml DBus Qml Gui)

add_unity8_plugin(Unity.Launcher 0.1 Unity/Launcher TARGETS UnityLauncher-qml)
