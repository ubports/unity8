pkg_check_modules(GSETTINGS_QT REQUIRED gsettings-qt)
pkg_check_modules(LAUNCHER_API REQUIRED unity-shell-launcher=5)
pkg_check_modules(APPLICATION_API REQUIRED unity-shell-application=6)

include_directories(
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_SOURCE_DIR}/plugins/AccountsService
    ${CMAKE_SOURCE_DIR}/plugins/Unity/Launcher
    ${GSETTINGS_QT_INCLUDE_DIRS}
    ${libunity8-private_SOURCE_DIR}
    )

add_definitions(-DSM_BUSNAME=sessionBus)
add_definitions(-DSRCDIR="${CMAKE_CURRENT_SOURCE_DIR}")
add_definitions(-DLAUNCHER_TESTING)

### LauncherModelTest
set(testModelCommand dbus-test-runner --task ${CMAKE_CURRENT_BINARY_DIR}/launchermodeltestExec
      --parameter -o --parameter ${CMAKE_BINARY_DIR}/launchermodeltest.xml,xunitxml
      --parameter -o --parameter -,txt)
add_test(NAME launchermodeltest COMMAND ${testModelCommand})
add_custom_target(launchermodeltest ${testModelCommand})
add_executable(launchermodeltestExec
    launchermodeltest.cpp
    gsettings.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Unity/Launcher/launchermodel.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Unity/Launcher/launcheritem.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Unity/Launcher/quicklistmodel.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Unity/Launcher/dbusinterface.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Unity/Launcher/desktopfilehandler.cpp
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
    )
qt5_use_modules(launchermodeltestExec Test Core DBus Xml Gui)

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
