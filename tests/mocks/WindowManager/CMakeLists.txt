include_directories(
    SYSTEM
    ${QTMIRSERVER_INCLUDE_DIRS}
    ${Qt5Gui_PRIVATE_INCLUDE_DIRS}
)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_SOURCE_DIR}/plugins/WindowManager
    ${libunity8-private_SOURCE_DIR}
)

add_library(mockwindowmanagmentpolicy SHARED
    WindowManagementPolicy.cpp
)
target_link_libraries(mockwindowmanagmentpolicy
    ${MIRAL_LDFLAGS}
    unity8-private
)
qt5_use_modules(mockwindowmanagmentpolicy Core)

install(TARGETS mockwindowmanagmentpolicy
    DESTINATION ${SHELL_INSTALL_QML}/mocks/WindowManager
    )

set(WINDOWMANAGER_SRC
    ${CMAKE_SOURCE_DIR}/plugins/WindowManager/AvailableDesktopArea.cpp
    ${CMAKE_SOURCE_DIR}/plugins/WindowManager/Screen.cpp
    ${CMAKE_SOURCE_DIR}/plugins/WindowManager/ScreenAttached.cpp
    ${CMAKE_SOURCE_DIR}/plugins/WindowManager/Screens.cpp
    ${CMAKE_SOURCE_DIR}/plugins/WindowManager/ScreenWindow.cpp
    ${CMAKE_SOURCE_DIR}/plugins/WindowManager/TopLevelWindowModel.cpp
    ${CMAKE_SOURCE_DIR}/plugins/WindowManager/Window.cpp
    ${CMAKE_SOURCE_DIR}/plugins/WindowManager/WindowMargins.cpp
    ${CMAKE_SOURCE_DIR}/plugins/WindowManager/WindowManagerObjects.cpp
    ${CMAKE_SOURCE_DIR}/plugins/WindowManager/WorkspaceManager.cpp
    ${CMAKE_SOURCE_DIR}/plugins/WindowManager/WorkspaceModel.cpp
    ${CMAKE_SOURCE_DIR}/plugins/WindowManager/Workspace.cpp
    MockScreens.cpp
    MockScreenWindow.cpp
    MockScreensConfiguration.cpp
    WindowManagerPlugin.cpp
    ${APPLICATION_API_INCLUDEDIR}/unity/shell/application/ApplicationInfoInterface.h
    ${APPLICATION_API_INCLUDEDIR}/unity/shell/application/ApplicationManagerInterface.h
    ${APPLICATION_API_INCLUDEDIR}/unity/shell/application/Mir.h
    ${APPLICATION_API_INCLUDEDIR}/unity/shell/application/MirSurfaceInterface.h
    ${APPLICATION_API_INCLUDEDIR}/unity/shell/application/MirSurfaceListInterface.h
    ${APPLICATION_API_INCLUDEDIR}/unity/shell/application/SurfaceManagerInterface.h
)

add_library(MockWindowManager-qml SHARED ${WINDOWMANAGER_SRC})

target_link_libraries(MockWindowManager-qml
    ${QTMIRSERVER_LDFLAGS}
    mockwindowmanagmentpolicy
)

qt5_use_modules(MockWindowManager-qml Qml Quick Gui)

add_unity8_mock(WindowManager 1.0 WindowManager TARGETS MockWindowManager-qml)
