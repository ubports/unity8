set(FakeUnityApplicationQml_SOURCES
    plugin.cpp
    ApplicationInfo.cpp
    ApplicationManager.cpp
    ApplicationTestInterface.cpp
    MirSurface.cpp
    MirSurfaceItem.cpp
    ObjectListModel.h
    Session.cpp
    SessionManager.cpp
    SurfaceManager.cpp
    SessionModel.h
    UbuntuKeyboardInfo.cpp
    VirtualKeyboard.cpp
    ${APPLICATION_API_INCLUDEDIR}/unity/shell/application/ApplicationInfoInterface.h
    ${APPLICATION_API_INCLUDEDIR}/unity/shell/application/ApplicationManagerInterface.h
    ${APPLICATION_API_INCLUDEDIR}/unity/shell/application/Mir.h
    ${APPLICATION_API_INCLUDEDIR}/unity/shell/application/MirSurfaceInterface.h
    ${APPLICATION_API_INCLUDEDIR}/unity/shell/application/MirSurfaceItemInterface.h
    resources/surfaces.qrc
)

add_library(FakeUnityApplicationQml MODULE ${FakeUnityApplicationQml_SOURCES})

add_library(NonMirUnityApplicationQml MODULE ${FakeUnityApplicationQml_SOURCES})
set_target_properties(NonMirUnityApplicationQml PROPERTIES OUTPUT_NAME FakeUnityApplicationQml)

qt5_use_modules(FakeUnityApplicationQml Core Quick DBus)
qt5_use_modules(NonMirUnityApplicationQml Core Quick DBus)

add_unity8_mock(Unity.Application 0.1 Unity/Application PREFIX mocks TARGETS FakeUnityApplicationQml)
add_unity8_mock(Unity.Application 0.1 Unity/Application
                PREFIX nonmirplugins
                TARGETS NonMirUnityApplicationQml
                BINARY_DIR ${CMAKE_BINARY_DIR}/nonmirplugins
                NO_TYPES)
