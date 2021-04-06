pkg_check_modules(GSETTINGS_QT REQUIRED gsettings-qt)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_SOURCE_DIR}/plugins/AccountsService
    ${CMAKE_SOURCE_DIR}/plugins/Unity/Launcher
    ${libunity8-private_SOURCE_DIR}
    )

include_directories(
    SYSTEM
    ${GSETTINGS_QT_INCLUDE_DIRS}
    ${GLIB_INCLUDE_DIRS}
    ${UAL_INCLUDE_DIRS}
    )

add_definitions(-DSM_BUSNAME=sessionBus)
add_definitions(-DTEST_DIR="plugins/Unity/Launcher")

### LauncherModelTest
add_executable(launchermodeltestExec
    launchermodeltest.cpp
    gsettings.cpp
    ${CMAKE_SOURCE_DIR}/plugins/AccountsService/AccountsServiceDBusAdaptor.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Unity/Launcher/launchermodel.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Unity/Launcher/asadapter.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Unity/Launcher/launcheritem.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Unity/Launcher/quicklistmodel.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Unity/Launcher/dbusinterface.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Unity/Launcher/quicklistentry.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Unity/Launcher/ualwrapper.cpp
    ${LAUNCHER_API_INCLUDEDIR}/lomiri/shell/launcher/LauncherItemInterface.h
    ${LAUNCHER_API_INCLUDEDIR}/lomiri/shell/launcher/LauncherModelInterface.h
    ${LAUNCHER_API_INCLUDEDIR}/lomiri/shell/launcher/QuickListModelInterface.h
    ${APPLICATION_API_INCLUDEDIR}/lomiri/shell/application/ApplicationManagerInterface.h
    ${APPLICATION_API_INCLUDEDIR}/lomiri/shell/application/MirSurfaceListInterface.h
    ${APPLICATION_API_INCLUDEDIR}/lomiri/shell/application/MirSurfaceInterface.h
    ${APPLICATION_API_INCLUDEDIR}/lomiri/shell/application/Mir.h
    ${LAUNCHER_API_INCLUDEDIR}/lomiri/shell/application/ApplicationInfoInterface.h
    )
target_link_libraries(launchermodeltestExec
    unity8-private
    ${GSETTINGS_QT_LDFLAGS}
    ${GLIB_LIBRARIES}
    ${UAL_LIBRARIES}
    Qt5::Test Qt5::Core Qt5::DBus Qt5::Xml Qt5::Gui Qt5::Qml
    )
add_dependencies(launchermodeltestExec mock-server)
install(TARGETS launchermodeltestExec
    DESTINATION "${SHELL_PRIVATE_LIBDIR}/tests/plugins/Unity/Launcher"
    )

add_unity8_unittest(LauncherModel dbus-test-runner
    ENVIRONMENT "APPDIR=${CMAKE_CURRENT_BINARY_DIR}/applications"
    ARG_PREFIX "--parameter"
    ARGS
        --task $<TARGET_FILE:mock-server>
        --ignore-return
        --task $<TARGET_FILE:launchermodeltestExec>
        --wait-for org.freedesktop.Accounts
)

### AppDrawerModelTest
add_executable(appdrawermodeltestExec
    appdrawermodeltest.cpp
    ualwrapper.cpp
    xdgwatcher.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Unity/Launcher/appdrawermodel.cpp
    ${LAUNCHER_API_INCLUDEDIR}/lomiri/shell/launcher/AppDrawerModelInterface.h
    ${CMAKE_SOURCE_DIR}/plugins/Unity/Launcher/launcheritem.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Unity/Launcher/quicklistmodel.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Unity/Launcher/quicklistentry.cpp
    ${LAUNCHER_API_INCLUDEDIR}/lomiri/shell/launcher/LauncherItemInterface.h
    ${LAUNCHER_API_INCLUDEDIR}/lomiri/shell/launcher/QuickListModelInterface.h
    )
target_link_libraries(appdrawermodeltestExec
    unity8-private
    ${GSETTINGS_QT_LDFLAGS}
    ${GLIB_LIBRARIES}
    ${UAL_LIBRARIES}
    Qt5::Test Qt5::Core Qt5::DBus Qt5::Xml Qt5::Gui Qt5::Qml Qt5::Concurrent
    )
add_dependencies(appdrawermodeltestExec mock-server)
install(TARGETS appdrawermodeltestExec
    DESTINATION "${SHELL_PRIVATE_LIBDIR}/tests/plugins/Unity/Launcher"
    )

add_unity8_unittest(AppDrawerModel dbus-test-runner
    ENVIRONMENT "APPDIR=${CMAKE_CURRENT_BINARY_DIR}/applications"
    ARG_PREFIX "--parameter"
    ARGS
        --task $<TARGET_FILE:mock-server>
        --ignore-return
        --task $<TARGET_FILE:appdrawermodeltestExec>
        --wait-for org.freedesktop.Accounts
)

# copy sample application files into build directory for shadow builds
file(COPY applications
     DESTINATION ${CMAKE_CURRENT_BINARY_DIR}
    )
install(DIRECTORY applications
    DESTINATION "${SHELL_PRIVATE_LIBDIR}/tests/plugins/Unity/Launcher"
    )
