pkg_check_modules(LAUNCHER_API REQUIRED unity-shell-launcher=7)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_SOURCE_DIR}/plugins/Greeter/Unity/Launcher
    ${libunity8-private_SOURCE_DIR}
    )

add_definitions(-DSM_BUSNAME=sessionBus)
add_definitions(-DSRCDIR="${CMAKE_CURRENT_SOURCE_DIR}")
add_definitions(-DLAUNCHER_TESTING)

### LauncherModelASTest
add_executable(launchermodelastestExec
    launchermodelastest.cpp
    AccountsServiceDBusAdaptor.cpp
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
qt5_use_modules(launchermodelastestExec Test Core DBus Gui)
add_unity8_unittest(LauncherModelAS dbus-test-runner
    ARG_PREFIX "--parameter"
    ARGS --task $<TARGET_FILE:launchermodelastestExec>
)

# copy .desktop files into build directory for shadow builds
file(GLOB DESKTOP_FILES *.desktop)

foreach(DESKTOP_FILE ${DESKTOP_FILES})
    file(COPY "${DESKTOP_FILE}"
        DESTINATION ${CMAKE_CURRENT_BINARY_DIR}
        )
endforeach()

# copy .svg files into build directory for shadow builds
file(GLOB DESKTOP_FILES *.svg)

foreach(DESKTOP_FILE ${DESKTOP_FILES})
    file(COPY "${DESKTOP_FILE}"
        DESTINATION ${CMAKE_CURRENT_BINARY_DIR}
        )
endforeach()
