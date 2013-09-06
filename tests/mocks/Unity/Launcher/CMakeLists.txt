include(FindPkgConfig)
pkg_check_modules(LAUNCHER_API REQUIRED unity-shell-launcher=2)

add_definitions(-DTOP_SRCDIR="${CMAKE_SOURCE_DIR}")

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
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
