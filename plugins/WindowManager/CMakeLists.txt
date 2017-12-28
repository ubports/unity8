set(WINDOWMANAGER_SRC
    AvailableDesktopArea.cpp
    TopLevelWindowModel.cpp
    Window.cpp
    WindowManagerPlugin.cpp
    WindowMargins.cpp
    ${APPLICATION_API_INCLUDEDIR}/unity/shell/application/ApplicationInfoInterface.h
    ${APPLICATION_API_INCLUDEDIR}/unity/shell/application/Mir.h
    ${APPLICATION_API_INCLUDEDIR}/unity/shell/application/MirSurfaceInterface.h
    ${APPLICATION_API_INCLUDEDIR}/unity/shell/application/MirSurfaceListInterface.h
    ${APPLICATION_API_INCLUDEDIR}/unity/shell/application/SurfaceManagerInterface.h
   )

add_definitions(-DWINDOWMANAGERQML_LIBRARY)

include_directories(
    SYSTEM
    ${Qt5Gui_PRIVATE_INCLUDE_DIRS}
)

add_library(windowmanager-qml SHARED ${WINDOWMANAGER_SRC})

qt5_use_modules(windowmanager-qml Qml Quick Gui)

add_unity8_plugin(WindowManager 0.1 WindowManager TARGETS windowmanager-qml)
