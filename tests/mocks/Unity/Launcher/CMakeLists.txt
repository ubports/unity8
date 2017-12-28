include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_SOURCE_DIR}/plugins/Unity/Launcher/
)

set(MockLauncherModel_SOURCES
    ${APPLICATION_API_INCLUDEDIR}/unity/shell/application/ApplicationManagerInterface.h
    ${LAUNCHER_API_INCLUDEDIR}/unity/shell/launcher/LauncherItemInterface.h
    ${LAUNCHER_API_INCLUDEDIR}/unity/shell/launcher/LauncherModelInterface.h
    ${LAUNCHER_API_INCLUDEDIR}/unity/shell/launcher/QuickListModelInterface.h
    ${LAUNCHER_API_INCLUDEDIR}/unity/shell/launcher/AppDrawerModelInterface.h
    plugin.cpp
    MockLauncherModel.cpp
    MockLauncherItem.cpp
    MockQuickListModel.cpp
    MockAppDrawerModel.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Utils/applicationsfiltermodel.cpp
)

add_library(MockLauncherPlugin MODULE ${MockLauncherModel_SOURCES})

qt5_use_modules(MockLauncherPlugin Core Quick)

add_unity8_mock(Unity.Launcher 0.1 Unity/Launcher TARGETS MockLauncherPlugin)
