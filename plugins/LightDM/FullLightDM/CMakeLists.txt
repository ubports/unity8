pkg_check_modules(LIBLIGHTDM REQUIRED liblightdm-qt5-3)

set(PLUGIN_CLASSNAME "FullLightDM")

add_definitions(-DFULL_LIGHTDM)

include_directories(
    ../
    ${LIBLIGHTDM_INCLUDE_DIRS}
    )

foreach(source_file ${QMLPLUGIN_SRC})
    list(APPEND RELATIVE_QMLPLUGIN_SRC ../${source_file})
endforeach()

add_library(FullLightDM-qml MODULE
    ${RELATIVE_QMLPLUGIN_SRC}
    )

target_link_libraries(FullLightDM-qml
    unity8-private
    ${LIBLIGHTDM_LDFLAGS}
    ${LIBUSERMETRICSOUTPUT_LDFLAGS}
    )

qt5_use_modules(FullLightDM-qml DBus Gui Qml)
add_unity8_plugin(FullLightDM 0.1 LightDM/FullLightDM TARGETS FullLightDM-qml)
