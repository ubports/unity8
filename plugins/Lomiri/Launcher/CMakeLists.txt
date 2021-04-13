pkg_check_modules(GSETTINGS_QT REQUIRED gsettings-qt)

add_definitions(-DSM_BUSNAME=systemBus)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_SOURCE_DIR}/plugins/AccountsService
    ${liblomiri-private_SOURCE_DIR}
)

include_directories(
    SYSTEM
    ${GSETTINGS_QT_INCLUDE_DIRS}
    ${GLIB_INCLUDE_DIRS}
    ${UAL_INCLUDE_DIRS}
    )

set(QMLLAUNCHERPLUGIN_SRC
    plugin.cpp
    launchermodel.cpp
    launcheritem.cpp
    quicklistmodel.cpp
    quicklistentry.cpp
    dbusinterface.cpp
    gsettings.cpp
    asadapter.cpp
    appdrawermodel.cpp
    ualwrapper.cpp
    xdgwatcher.cpp
    ${CMAKE_SOURCE_DIR}/plugins/AccountsService/AccountsServiceDBusAdaptor.cpp
    ${APPLICATION_API_INCLUDEDIR}/lomiri/shell/application/ApplicationManagerInterface.h
    ${APPLICATION_API_INCLUDEDIR}/lomiri/shell/application/ApplicationInfoInterface.h
    ${APPLICATION_API_INCLUDEDIR}/lomiri/shell/application/MirSurfaceListInterface.h
    ${APPLICATION_API_INCLUDEDIR}/lomiri/shell/application/MirSurfaceInterface.h
    ${APPLICATION_API_INCLUDEDIR}/lomiri/shell/application/Mir.h
    ${LAUNCHER_API_INCLUDEDIR}/lomiri/shell/launcher/LauncherItemInterface.h
    ${LAUNCHER_API_INCLUDEDIR}/lomiri/shell/launcher/LauncherModelInterface.h
    ${LAUNCHER_API_INCLUDEDIR}/lomiri/shell/launcher/QuickListModelInterface.h
    ${LAUNCHER_API_INCLUDEDIR}/lomiri/shell/launcher/AppDrawerModelInterface.h
    )

add_library(LomiriLauncher-qml MODULE
    ${QMLLAUNCHERPLUGIN_SRC}
    )

target_link_libraries(LomiriLauncher-qml
    lomiri-private
    ${GSETTINGS_QT_LDFLAGS}
    ${GLIB_LIBRARIES}
    ${UAL_LIBRARIES}
    Qt5::DBus Qt5::Qml Qt5::Gui Qt5::Concurrent
    )

add_lomiri_plugin(Lomiri.Launcher 0.1 Lomiri/Launcher TARGETS LomiriLauncher-qml)
