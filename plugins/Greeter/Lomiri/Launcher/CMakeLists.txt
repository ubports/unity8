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
    ${APPLICATION_API_INCLUDEDIR}/lomiri/shell/application/ApplicationManagerInterface.h
    ${LAUNCHER_API_INCLUDEDIR}/lomiri/shell/launcher/LauncherItemInterface.h
    ${LAUNCHER_API_INCLUDEDIR}/lomiri/shell/launcher/LauncherModelInterface.h
    ${LAUNCHER_API_INCLUDEDIR}/lomiri/shell/launcher/QuickListModelInterface.h
    )

add_library(LomiriLauncherAS-qml MODULE
    ${QMLLAUNCHERPLUGINAS_SRC}
    )

target_link_libraries(LomiriLauncherAS-qml
    lomiri-private
    ${GSETTINGS_QT_LDFLAGS}
    Qt5::DBus Qt5::Qml Qt5::Gui
    )

add_lomiri_greeter_plugin(Lomiri.Launcher 0.1 Lomiri/Launcher TARGETS LomiriLauncherAS-qml)
