# export_qmlplugin macro
include(Plugins)

# Dependencies
include(FindPkgConfig)
pkg_check_modules(LIBLIGHTDM REQUIRED liblightdm-qt5-3)
pkg_check_modules(LIBUSERMETRICSOUTPUT REQUIRED libusermetricsoutput-1)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
    ${LIBLIGHTDM_INCLUDE_DIRS}
    ${LIBUSERMETRICSOUTPUT_INCLUDE_DIRS}
)

set(QMLPLUGIN_SRC
    ${CMAKE_SOURCE_DIR}/plugins/Utils/qsortfilterproxymodelqml.cpp # FIXME evaluate a more generic approach for using other plugins
    Greeter.cpp
    plugin.cpp
    UsersModel.cpp
    )

add_library(LightDM-qml MODULE
    ${QMLPLUGIN_SRC}
    )

target_link_libraries(LightDM-qml
    ${LIBLIGHTDM_LDFLAGS}
    ${LIBUSERMETRICSOUTPUT_LDFLAGS}
    )

qt5_use_modules(LightDM-qml Qml)

# export the qmldir qmltypes and plugin files
export_qmlfiles(LightDM LightDM)
export_qmlplugin(LightDM 0.1 LightDM TARGETS LightDM-qml)
