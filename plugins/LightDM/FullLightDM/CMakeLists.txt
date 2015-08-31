pkg_check_modules(LIBLIGHTDM REQUIRED liblightdm-qt5-3)

set(PLUGIN_CLASSNAME "FullLightDM")

# Written to source dir as thats where add_unity8_plugin expects it
configure_file(../qmldir.in ${CMAKE_CURRENT_SOURCE_DIR}/qmldir)

add_definitions(-DFULL_LIGHTDM)

include_directories(../)

foreach(source_file ${QMLPLUGIN_SRC})
    list(APPEND RELATIVE_QMLPLUGIN_SRC ../${source_file})
endforeach()

add_library(FullLightDM-qml MODULE
    ${RELATIVE_QMLPLUGIN_SRC}
    )

target_link_libraries(FullLightDM-qml
    unity8-private
    lightdm-qt5-3
    ${LIBLIGHTDM_LDFLAGS}
    ${LIBUSERMETRICSOUTPUT_LDFLAGS}
    )

qt5_use_modules(FullLightDM-qml DBus Gui Qml)
add_unity8_plugin(FullLightDM 0.1 LightDM/FullLightDM TARGETS FullLightDM-qml)
