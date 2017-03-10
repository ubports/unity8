include_directories(
    SYSTEM
    ${QTMIRSERVER_INCLUDE_DIRS}
)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${libunity8-private_SOURCE_DIR}
)

set(WINDOWMANAGER_SRC
    TopLevelWindowModel.cpp
    Window.cpp
    WindowManagerPlugin.cpp
    Screen.cpp
    ScreenAttached.cpp
    Screens.cpp
    ScreenWindow.cpp
    Workspace.cpp
    WorkspaceManager.cpp
    WorkspaceModel.cpp
    ${APPLICATION_API_INCLUDEDIR}/unity/shell/application/ApplicationInfoInterface.h
    ${APPLICATION_API_INCLUDEDIR}/unity/shell/application/Mir.h
    ${APPLICATION_API_INCLUDEDIR}/unity/shell/application/MirSurfaceInterface.h
    ${APPLICATION_API_INCLUDEDIR}/unity/shell/application/MirSurfaceListInterface.h
    ${APPLICATION_API_INCLUDEDIR}/unity/shell/application/SurfaceManagerInterface.h
)

add_library(windowmanager-qml SHARED ${WINDOWMANAGER_SRC})

target_link_libraries(windowmanager-qml
    ${QTMIRSERVER_LDFLAGS}
    unity8-private
)

qt5_use_modules(windowmanager-qml Qml Quick Gui)

add_unity8_plugin(WindowManager 1.0 WindowManager TARGETS windowmanager-qml)
