include(FindPkgConfig)
pkg_check_modules(APPLICATION_API REQUIRED unity-shell-application=4)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
)

set(QMLDASHCOMMUNICATORPLUGIN_SRC
    plugin.cpp
    dbusdashcommunicatorservice.cpp
    dashcommunicatorservice.cpp
    dashcommunicator.cpp
    ${APPLICATION_API_INCLUDEDIR}/unity/shell/application/ApplicationManagerInterface.h
    )

add_library(DashCommunicator-qml MODULE
    ${QMLDASHCOMMUNICATORPLUGIN_SRC}
    )

qt5_use_modules(DashCommunicator-qml DBus Qml)

# export the qmldir and qmltypes files
add_unity8_plugin(Unity.DashCommunicator 0.1 Unity/DashCommunicator TARGETS DashCommunicator-qml)
