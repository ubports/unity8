set(CMAKE_AUTOMOC ON)

include(FindPkgConfig)
find_package(Qt5Core REQUIRED)
find_package(Qt5Quick REQUIRED)

pkg_check_modules(LAUNCHER_API REQUIRED unity-shell-launcher)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${LAUNCHER_API_INCLUDEDIR}
)

set(MockLauncherModel_SOURCES
    ${LAUNCHER_API_INCLUDEDIR}/unity/shell/launcher/LauncherItemInterface.h
    ${LAUNCHER_API_INCLUDEDIR}/unity/shell/launcher/LauncherModelInterface.h
    ${LAUNCHER_API_INCLUDEDIR}/unity/shell/launcher/QuickListModelInterface.h
    plugin.cpp
    MockLauncherModel.cpp
    MockLauncherItem.cpp
    MockQuickListModel.cpp
)

add_library(MockLauncherPlugin MODULE ${MockLauncherModel_SOURCES})

qt5_use_modules(MockLauncherPlugin Core Quick)

# copy files into build directory for shadow builds
add_custom_target(LauncherPluginQmlDirFile ALL
    COMMAND cp "${CMAKE_CURRENT_SOURCE_DIR}/qmldir" ${CMAKE_CURRENT_BINARY_DIR}
    DEPENDS qmldir
)

install(TARGETS MockLauncherPlugin
    DESTINATION ${SHELL_APP_DIR}/plugins/mocks/Unity/Launcher
    )

install(FILES qmldir
    DESTINATION ${SHELL_APP_DIR}/plugins/mocks/Unity/Launcher
    )
