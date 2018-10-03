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

target_link_libraries(MockDashCommunicator-qml Qt5::DBus Qt5::Qml)

# export the qmldir and qmltypes files
add_unity8_mock(Unity.DashCommunicator 0.1 Unity/DashCommunicator TARGETS MockDashCommunicator-qml)
