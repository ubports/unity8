# Dependencies
include(FindPkgConfig)

#TODO: remove this once unity-api is released to distro
set(UNITY_API_DIR /home/mzanetti/Development/unity-api/include/)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
    ${UNITY_API_DIR}
)

set(QMLLAUNCHERPLUGIN_SRC
    plugin.cpp
    launchermodel.cpp
    launcheritem.cpp
    ${UNITY_API_DIR}/unity/shell/launcher/LauncherItemInterface.h
    ${UNITY_API_DIR}/unity/shell/launcher/LauncherModelInterface.h
    )

add_library(UnityLauncher-qml MODULE
    ${QMLLAUNCHERPLUGIN_SRC}
    )

qt5_use_modules(UnityLauncher-qml Qml)

# copy qmldir file into build directory for shadow builds
file(COPY "${CMAKE_CURRENT_SOURCE_DIR}/qmldir"
    DESTINATION ${CMAKE_CURRENT_BINARY_DIR}
    )

install(TARGETS UnityLauncher-qml
    DESTINATION ${SHELL_APP_DIR}/plugins/Unity/Launcher/
    )

install(FILES qmldir
    DESTINATION ${SHELL_APP_DIR}/plugins/Unity/Launcher/
    )
