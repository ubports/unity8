pkg_check_modules(GSETTINGS_QT REQUIRED gsettings-qt)

add_definitions(-DSM_BUSNAME=systemBus)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_SOURCE_DIR}/plugins/AccountsService
    ${GSETTINGS_QT_INCLUDE_DIRS}
    ${liblomiri-private_SOURCE_DIR}
)

set(QMLLAUNCHERPLUGINAS_SRC
    plugin.cpp
    launchermodelas.cpp
    launcheritem.cpp
    quicklistmodel.cpp
    quicklistentry.cpp
    ${CMAKE_SOURCE_DIR}/plugins/AccountsService/AccountsServiceDBusAdaptor.cpp
    ${APPLICATION_API_INCLUDEDIR}/unity/shell/application/ApplicationManagerInterface.h
    ${LAUNCHER_API_INCLUDEDIR}/unity/shell/launcher/LauncherItemInterface.h
    ${LAUNCHER_API_INCLUDEDIR}/unity/shell/launcher/LauncherModelInterface.h
    ${LAUNCHER_API_INCLUDEDIR}/unity/shell/launcher/QuickListModelInterface.h
    )

add_library(UnityLauncherAS-qml MODULE
    ${QMLLAUNCHERPLUGINAS_SRC}
    )

target_link_libraries(UnityLauncherAS-qml
    lomiri-private
    ${GSETTINGS_QT_LDFLAGS}
    Qt5::DBus Qt5::Qml Qt5::Gui
    )

add_lomiri_greeter_plugin(Unity.Launcher 0.1 Unity/Launcher TARGETS UnityLauncherAS-qml)
