pkg_check_modules(APPLICATION_API REQUIRED unity-shell-application)

set(FakeUnityApplicationQml_SOURCES
    plugin.cpp
    ApplicationInfo.cpp
    ApplicationImage.cpp
    ApplicationManager.cpp
    ApplicationScreenshotProvider.cpp
    ${APPLICATION_API_INCLUDEDIR}/unity/shell/application/ApplicationInfoInterface.h
    ${APPLICATION_API_INCLUDEDIR}/unity/shell/application/ApplicationManagerInterface.h
)

add_library(FakeUnityApplicationQml MODULE ${FakeUnityApplicationQml_SOURCES})

qt5_use_modules(FakeUnityApplicationQml Core Quick)

add_unity8_mock(Unity.Application 0.1 Unity/Application PREFIX mocks TARGETS FakeUnityApplicationQml)
add_unity8_mock(Unity.Application 0.1 Unity/Application PREFIX nonmirplugins TARGETS FakeUnityApplicationQml)
