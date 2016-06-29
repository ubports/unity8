set(WINDOWMANAGER_SRC
    TopLevelSurfaceList.cpp
    WindowManagerPlugin.cpp
    ${APPLICATION_API_INCLUDEDIR}/unity/shell/application/ApplicationInfoInterface.h
    ${APPLICATION_API_INCLUDEDIR}/unity/shell/application/Mir.h
    ${APPLICATION_API_INCLUDEDIR}/unity/shell/application/MirSurfaceInterface.h
    ${APPLICATION_API_INCLUDEDIR}/unity/shell/application/MirSurfaceListInterface.h
   )

add_library(windowmanager-qml SHARED ${WINDOWMANAGER_SRC})

qt5_use_modules(windowmanager-qml Qml Quick Gui)

add_unity8_plugin(WindowManager 0.1 WindowManager TARGETS windowmanager-qml)
