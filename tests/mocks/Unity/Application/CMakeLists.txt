pkg_check_modules(APPLICATION_API REQUIRED unity-shell-application=3)

set(FakeUnityApplicationQml_SOURCES
    plugin.cpp
    ApplicationInfo.cpp
    ApplicationManager.cpp
    ApplicationScreenshotProvider.cpp
    ApplicationTestInterface.cpp
    Session.cpp
    MirSurfaceItem.cpp
    SessionManager.cpp
    SurfaceManager.cpp
    MirObjectModel.h
    MirSurfaceItemModel.h
    SessionModel.h
    ${APPLICATION_API_INCLUDEDIR}/unity/shell/application/ApplicationInfoInterface.h
    ${APPLICATION_API_INCLUDEDIR}/unity/shell/application/ApplicationManagerInterface.h
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
