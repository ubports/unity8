include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
    ${libunity8-private_SOURCE_DIR}
)

set(QMLDASHCOMMUNICATORPLUGIN_SRC
    plugin.cpp
    dbusdashcommunicatorservice.cpp
    dashcommunicatorservice.cpp
    dashcommunicator.cpp
    dashconnection.cpp
)

add_library(DashCommunicator-qml MODULE
    ${QMLDASHCOMMUNICATORPLUGIN_SRC}
)

qt5_use_modules(DashCommunicator-qml DBus Qml)

target_link_libraries(DashCommunicator-qml
    unity8-private
)

# export the qmldir and qmltypes files
add_unity8_plugin(Unity.DashCommunicator 0.1 Unity/DashCommunicator TARGETS DashCommunicator-qml)
