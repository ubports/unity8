set(CMAKE_AUTOMOC ON)

include(FindPkgConfig)
find_package(Qt5Core REQUIRED)
find_package(Qt5Quick REQUIRED)

#TODO: fix this once unity-api is released to distro
set(UNITY_API_DIR /home/mzanetti/Development/unity-api/include/)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${UNITY_API_DIR}
)

set(MockLauncherModel_SOURCES
    ${UNITY_API_DIR}/unity/shell/launcher/LauncherModelInterface.h
    ${UNITY_API_DIR}/unity/shell/launcher/LauncherItemInterface.h
    plugin.cpp
    MockLauncherModel.cpp
    MockLauncherItem.cpp
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
