# export_qmlplugin macro
include(Plugins)

add_subdirectory(Indicators)

# Dependencies
include(FindPkgConfig)
pkg_check_modules(QTDEE REQUIRED libdee-qt5>=3.2)
pkg_check_modules(UNITYCORE REQUIRED unity-core-6.0>=7.1.1)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
    ${QTDEE_INCLUDE_DIRS}
    ${UNITYCORE_INCLUDE_DIRS}
    ${Qt5DBus_INCLUDE_DIRS}
)

set(QMLPLUGIN_SRC
    abstractfilteroption.cpp
    scope.cpp
    scopes.cpp
    categories.cpp
    checkoptionfilter.cpp
    filter.cpp
    filteroption.cpp
    filters.cpp
    genericoptionsmodel.cpp
    ratingoptionsmodel.cpp
    unityoptionsmodel.cpp
    categoryresults.cpp
    plugin.cpp
    multirangefilter.cpp
    radiooptionfilter.cpp
    ratingsfilter.cpp
    ratingfilteroption.cpp
    applicationpreview.cpp
    genericpreview.cpp
    moviepreview.cpp
    musicpreview.cpp
    musicpreviewtrackmodel.cpp
    preview.cpp
    previewaction.cpp
    previewinfohint.cpp
    result.cpp
    showallfilteroption.cpp
    signalslist.cpp
    socialpreview.cpp
    socialpreviewcomment.cpp
    iconutils.cpp
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

# export the qmldir qmltypes and plugin files
export_qmlfiles(Unity Unity)
export_qmlplugin(Unity 0.1 Unity TARGETS Unity-qml)

add_subdirectory(Launcher)
