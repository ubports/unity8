include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_SOURCE_DIR}/plugins/AccountsService
    ${CMAKE_SOURCE_DIR}/plugins/Greeter/Unity/Launcher
    ${libunity8-private_SOURCE_DIR}
    )

add_definitions(-DSM_BUSNAME=sessionBus)
add_definitions(-DTEST_DIR="plugins/Greeter/Unity/Launcher")

### LauncherModelASTest
add_executable(launchermodelastestExec
    launchermodelastest.cpp
    ${CMAKE_SOURCE_DIR}/plugins/AccountsService/AccountsServiceDBusAdaptor.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Greeter/Unity/Launcher/launchermodelas.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Greeter/Unity/Launcher/launcheritem.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Greeter/Unity/Launcher/quicklistmodel.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Greeter/Unity/Launcher/quicklistentry.cpp
    ${LAUNCHER_API_INCLUDEDIR}/unity/shell/launcher/LauncherItemInterface.h
    ${LAUNCHER_API_INCLUDEDIR}/unity/shell/launcher/LauncherModelInterface.h
    ${LAUNCHER_API_INCLUDEDIR}/unity/shell/launcher/QuickListModelInterface.h
    ${APPLICATION_API_INCLUDEDIR}/unity/shell/application/ApplicationManagerInterface.h
    ${LAUNCHER_API_INCLUDEDIR}/unity/shell/application/ApplicationInfoInterface.h
    )
target_link_libraries(launchermodelastestExec
    unity8-private
    ${GSETTINGS_QT_LDFLAGS}
    )
add_dependencies(launchermodelastestExec mock-server)
qt5_use_modules(launchermodelastestExec Test Core DBus Gui Qml)
install(TARGETS launchermodelastestExec
    DESTINATION "${SHELL_PRIVATE_LIBDIR}/tests/plugins/Greeter/Unity/Launcher"
)
add_unity8_unittest(LauncherModelAS dbus-test-runner
    ARG_PREFIX "--parameter"
    ARGS
        --task $<TARGET_FILE:mock-server>
        --ignore-return
        --task $<TARGET_FILE:launchermodelastestExec>
        --wait-for org.freedesktop.Accounts
)
