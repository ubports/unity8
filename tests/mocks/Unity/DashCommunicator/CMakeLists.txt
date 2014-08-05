include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
)

set(QMLDASHCOMMUNICATORPLUGIN_SRC
    plugin.cpp
    dashcommunicatorservice.cpp
    dashcommunicator.cpp
    )

add_library(MockDashCommunicator-qml MODULE
    ${QMLDASHCOMMUNICATORPLUGIN_SRC}
    )

qt5_use_modules(MockDashCommunicator-qml DBus Qml)

# export the qmldir and qmltypes files
add_unity8_mock(Unity.DashCommunicator 0.1 Unity/DashCommunicator TARGETS MockDashCommunicator-qml)
