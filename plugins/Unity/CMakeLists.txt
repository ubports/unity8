add_subdirectory(Indicators)

# Dependencies
include(FindPkgConfig)
pkg_check_modules(QTDEE REQUIRED libdee-qt5)
pkg_check_modules(UNITYCORE REQUIRED unity-core-6.0)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
    ${QTDEE_INCLUDE_DIRS}
    ${UNITYCORE_INCLUDE_DIRS}
    ${Qt5DBus_INCLUDE_DIRS}
)

set(QMLPLUGIN_SRC
    ../Utils/qsortfilterproxymodelqml.cpp # FIXME evaluate a more generic approach for using other plugins
    scope.cpp
    scopes.cpp
    categories.cpp
    categoryfilter.cpp
    plugin.cpp
    bottombarvisibilitycommunicatorshell.cpp
    launchermodel.cpp
    applicationpreview.cpp
    genericpreview.cpp
    moviepreview.cpp
    musicpreview.cpp
    preview.cpp
    previewaction.cpp
    previewinfohint.cpp
    variantutils.cpp
    )

add_library(Unity-qml MODULE
    ${QMLPLUGIN_SRC}
    )

target_link_libraries(Unity-qml
    ${QTDEE_LDFLAGS}
    ${UNITYCORE_LDFLAGS}
    ${Qt5DBus_LIBRARIES}
    ${Qt5Gui_LIBRARIES}
    )

qt5_use_modules(Unity-qml Qml)

# copy qmldir file into build directory for shadow builds
file(COPY "${CMAKE_CURRENT_SOURCE_DIR}/qmldir"
    DESTINATION ${CMAKE_CURRENT_BINARY_DIR}
    )

install(TARGETS Unity-qml
    DESTINATION ${SHELL_PRIVATE_LIBDIR}/qml/Unity
    )

install(FILES qmldir
    DESTINATION ${SHELL_PRIVATE_LIBDIR}/qml/Unity
    )
