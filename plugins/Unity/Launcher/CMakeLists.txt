include(FindPkgConfig)
pkg_check_modules(GLIB REQUIRED glib-2.0>=2.32)
pkg_check_modules(LAUNCHER_API REQUIRED unity-shell-launcher=3)
pkg_check_modules(APPLICATION_API REQUIRED unity-shell-application=1)
pkg_check_modules(GSETTINGS_QT REQUIRED gsettings-qt)
pkg_check_modules(UPSTART_APP_LAUNCH REQUIRED upstart-app-launch-2)

add_definitions(-DSM_BUSNAME=systemBus)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_SOURCE_DIR}/plugins/AccountsService
    ${GLIB_INCLUDE_DIRS}
    ${GSETTINGS_QT_INCLUDE_DIRS}
    ${UPSTART_APP_LAUNCH_INCLUDE_DIRS}
)

set(QMLLAUNCHERPLUGIN_SRC
    plugin.cpp
    launchermodel.cpp
    launcheritem.cpp
    quicklistmodel.cpp
    common/quicklistentry.cpp
    backend/launcherbackend.cpp
    ${CMAKE_SOURCE_DIR}/plugins/AccountsService/AccountsServiceDBusAdaptor.cpp
    ${LAUNCHER_API_INCLUDEDIR}/unity/shell/launcher/LauncherItemInterface.h
    ${LAUNCHER_API_INCLUDEDIR}/unity/shell/launcher/LauncherModelInterface.h
    ${LAUNCHER_API_INCLUDEDIR}/unity/shell/launcher/QuickListModelInterface.h
    )

add_library(UnityLauncher-qml MODULE
    ${QMLLAUNCHERPLUGIN_SRC}
    )

target_link_libraries(UnityLauncher-qml
    ${GLIB_LDFLAGS}
    ${GSETTINGS_QT_LDFLAGS}
    ${UPSTART_APP_LAUNCH_LDFLAGS}
)

qt5_use_modules(UnityLauncher-qml DBus Qml)

add_unity8_plugin(Unity.Launcher 0.1 Unity/Launcher TARGETS UnityLauncher-qml)
