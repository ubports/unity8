include_directories(
 ${CMAKE_CURRENT_SOURCE_DIR}
)

add_library(UnityShell-qml MODULE
 plugin.cpp
 DBusUnityShellService.cpp
 )

qt5_use_modules(UnityShell-qml DBus Qml)

# export the qmldir and qmltypes files
add_unity8_plugin(Unity.Shell 0.1 Unity/Shell TARGETS UnityShell-qml)
