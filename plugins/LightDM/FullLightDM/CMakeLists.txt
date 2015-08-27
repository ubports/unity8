pkg_check_modules(LIBLIGHTDM REQUIRED liblightdm-qt5-3)

set(PLUGIN_CLASSNAME "FullLightDM")
configure_file(../qmldir.in ${CMAKE_CURRENT_BINARY_DIR}/qmldir)

add_definitions(-DFULL_LIGHTDM)

include_directories(../)

foreach(l ${QMLPLUGIN_SRC})
        list(APPEND "${${QMLPLUGIN_SRC}_TMP}" ../${l})
endforeach()

add_library(FullLightDM-qml MODULE
    ${QMLPLUGIN_SRC_TMP}
    )

target_link_libraries(FullLightDM-qml
    unity8-private
    lightdm-qt5-3
    ${LIBLIGHTDM_LDFLAGS}
    ${LIBUSERMETRICSOUTPUT_LDFLAGS}
    )

qt5_use_modules(FullLightDM-qml DBus Gui Qml)
add_unity8_plugin(FullLightDM 0.1 LightDM/FullLightDM TARGETS FullLightDM-qml)
