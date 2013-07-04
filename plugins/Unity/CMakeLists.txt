# export_qmlplugin macro
include(Plugins)

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

# export the qmldir and qmltypes files
export_qmlplugin(Unity 0.1 plugins Unity TARGETS Unity-qml)
