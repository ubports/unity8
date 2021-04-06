set(WINDOWMANAGER_SRC
    AvailableDesktopArea.cpp
    TopLevelWindowModel.cpp
    Window.cpp
    WindowManagerPlugin.cpp
    WindowMargins.cpp
    InputMethodManager.cpp
    ${APPLICATION_API_INCLUDEDIR}/lomiri/shell/application/ApplicationInfoInterface.h
    ${APPLICATION_API_INCLUDEDIR}/lomiri/shell/application/Mir.h
    ${APPLICATION_API_INCLUDEDIR}/lomiri/shell/application/MirSurfaceInterface.h
    ${APPLICATION_API_INCLUDEDIR}/lomiri/shell/application/MirSurfaceListInterface.h
    ${APPLICATION_API_INCLUDEDIR}/lomiri/shell/application/SurfaceManagerInterface.h
   )

add_definitions(-DWINDOWMANAGERQML_LIBRARY)

include_directories(
    SYSTEM
    ${Qt5Gui_PRIVATE_INCLUDE_DIRS}
)

add_library(windowmanager-qml SHARED ${WINDOWMANAGER_SRC})

target_link_libraries(windowmanager-qml Qt5::Qml Qt5::Quick Qt5::Gui)

add_unity8_plugin(WindowManager 0.1 WindowManager TARGETS windowmanager-qml)
