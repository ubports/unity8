pkg_check_modules(LAUNCHER_API REQUIRED unity-shell-launcher=3)

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

add_unity8_mock(Unity.Launcher 0.1 Unity/Launcher TARGETS MockLauncherPlugin)
