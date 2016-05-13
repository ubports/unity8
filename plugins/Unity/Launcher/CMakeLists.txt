pkg_check_modules(LAUNCHER_API REQUIRED unity-shell-launcher=9)
pkg_check_modules(GSETTINGS_QT REQUIRED gsettings-qt)

add_definitions(-DSM_BUSNAME=systemBus)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_SOURCE_DIR}/plugins/AccountsService
    ${GSETTINGS_QT_INCLUDE_DIRS}
    ${GLIB_INCLUDE_DIRS}
    ${libunity8-private_SOURCE_DIR}
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
    asadapter.cpp
    ${CMAKE_SOURCE_DIR}/plugins/AccountsService/AccountsServiceDBusAdaptor.cpp
    ${APPLICATION_API_INCLUDEDIR}/unity/shell/application/ApplicationManagerInterface.h
    ${APPLICATION_API_INCLUDEDIR}/unity/shell/application/ApplicationInfoInterface.h
    ${APPLICATION_API_INCLUDEDIR}/unity/shell/application/MirSurfaceListInterface.h
    ${LAUNCHER_API_INCLUDEDIR}/unity/shell/launcher/LauncherItemInterface.h
    ${LAUNCHER_API_INCLUDEDIR}/unity/shell/launcher/LauncherModelInterface.h
    ${LAUNCHER_API_INCLUDEDIR}/unity/shell/launcher/QuickListModelInterface.h
    )

add_library(UnityLauncher-qml MODULE
    ${QMLLAUNCHERPLUGIN_SRC}
    )

target_link_libraries(UnityLauncher-qml
    unity8-private
    ${GSETTINGS_QT_LDFLAGS}
    ${GLIB_LIBRARIES}
    )

qt5_use_modules(UnityLauncher-qml DBus Qml Gui)

add_unity8_plugin(Unity.Launcher 0.1 Unity/Launcher TARGETS UnityLauncher-qml)
