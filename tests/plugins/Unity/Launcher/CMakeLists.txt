pkg_check_modules(GSETTINGS_QT REQUIRED gsettings-qt)
pkg_check_modules(LAUNCHER_API REQUIRED unity-shell-launcher=10)

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
add_definitions(-DSRCDIR="${CMAKE_CURRENT_SOURCE_DIR}")

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
    ${LAUNCHER_API_INCLUDEDIR}/unity/shell/launcher/LauncherItemInterface.h
    ${LAUNCHER_API_INCLUDEDIR}/unity/shell/launcher/LauncherModelInterface.h
    ${LAUNCHER_API_INCLUDEDIR}/unity/shell/launcher/QuickListModelInterface.h
    ${APPLICATION_API_INCLUDEDIR}/unity/shell/application/ApplicationManagerInterface.h
    ${LAUNCHER_API_INCLUDEDIR}/unity/shell/application/ApplicationInfoInterface.h
    )
target_link_libraries(launchermodeltestExec
    unity8-private
    ${GSETTINGS_QT_LDFLAGS}
    ${GLIB_LIBRARIES}
    ${UAL_LIBRARIES}
    )
add_dependencies(launchermodeltestExec mock-server)
qt5_use_modules(launchermodeltestExec Test Core DBus Xml Gui)

add_unity8_unittest(LauncherModel dbus-test-runner
    ENVIRONMENT "XDG_DATA_HOME=${CMAKE_CURRENT_BINARY_DIR}"
    ARG_PREFIX "--parameter"
    ARGS
        --task $<TARGET_FILE:mock-server>
        --ignore-return
        --task $<TARGET_FILE:launchermodeltestExec>
        --wait-for org.freedesktop.Accounts
)

# copy sample application files into build directory for shadow builds
file(COPY applications
     DESTINATION ${CMAKE_CURRENT_BINARY_DIR}
    )
