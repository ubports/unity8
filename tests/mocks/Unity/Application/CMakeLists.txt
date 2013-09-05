include(FindPkgConfig)
pkg_check_modules(APPLICATION_API REQUIRED unity-shell-application)

set(FakeUnityApplicationQml_SOURCES
    plugin.cpp
    ApplicationInfo.cpp
    ApplicationImage.cpp
    ApplicationManager.cpp
    ${APPLICATION_API_INCLUDEDIR}/unity/shell/application/ApplicationInfoInterface.h
    ${APPLICATION_API_INCLUDEDIR}/unity/shell/application/ApplicationManagerInterface.h
)

add_library(FakeUnityApplicationQml MODULE ${FakeUnityApplicationQml_SOURCES})

qt5_use_modules(FakeUnityApplicationQml Core Quick)

# copy files into build directory for shadow builds
add_custom_target(UnityAppQmlDirFile ALL
    COMMAND cp "${CMAKE_CURRENT_SOURCE_DIR}/qmldir" ${CMAKE_CURRENT_BINARY_DIR}
    DEPENDS qmldir
)
add_custom_target(InputFilterAreaQmlFile ALL
    COMMAND cp "${CMAKE_CURRENT_SOURCE_DIR}/InputFilterArea.qml" ${CMAKE_CURRENT_BINARY_DIR}
    DEPENDS InputFilterArea.qml
)

install(TARGETS FakeUnityApplicationQml
    DESTINATION ${SHELL_PRIVATE_LIBDIR}/qml/mocks/Unity/Application
    )

install(FILES qmldir InputFilterArea.qml
    DESTINATION ${SHELL_PRIVATE_LIBDIR}/qml/mocks/Unity/Application
    )
