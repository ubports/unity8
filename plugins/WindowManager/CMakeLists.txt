include_directories(
    SYSTEM
    ${QTMIRSERVER_INCLUDE_DIRS}
    ${Qt5Gui_PRIVATE_INCLUDE_DIRS}
)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${libunity8-private_SOURCE_DIR}
)

set(WINDOWMANAGER_SRC
    AvailableDesktopArea.cpp
    TopLevelWindowModel.cpp
    Window.cpp
    WindowManagerPlugin.cpp
    WindowMargins.cpp
    Screen.cpp
    ScreenAttached.cpp
    Screens.cpp
    ScreensConfiguration.cpp
    ScreenWindow.cpp
    WindowManagerObjects.cpp
    Workspace.cpp
    WorkspaceManager.cpp
    WorkspaceModel.cpp
    ${APPLICATION_API_INCLUDEDIR}/unity/shell/application/ApplicationInfoInterface.h
    ${APPLICATION_API_INCLUDEDIR}/unity/shell/application/ApplicationManagerInterface.h
    ${APPLICATION_API_INCLUDEDIR}/unity/shell/application/Mir.h
    ${APPLICATION_API_INCLUDEDIR}/unity/shell/application/MirSurfaceInterface.h
    ${APPLICATION_API_INCLUDEDIR}/unity/shell/application/MirSurfaceListInterface.h
    ${APPLICATION_API_INCLUDEDIR}/unity/shell/application/SurfaceManagerInterface.h
)

add_definitions(-DWINDOWMANAGERQML_LIBRARY)

add_library(windowmanager-qml SHARED ${WINDOWMANAGER_SRC})

target_link_libraries(windowmanager-qml
    ${QTMIRSERVER_LDFLAGS}
    unity8-private
)

qt5_use_modules(windowmanager-qml Qml Quick Gui)

add_unity8_plugin(WindowManager 1.0 WindowManager TARGETS windowmanager-qml)
