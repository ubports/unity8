set(PLUGIN_CLASSNAME "IntegratedLightDM")

add_definitions(-DINTEGRATED_LIGHTDM)

foreach(include_directory ${QMLPLUGIN_INCLUDES})
        list(APPEND RELATIVE_QMLPLUGIN_INCLUDES ../${include_directory})
endforeach()

include_directories(
    . #QLightDM
    ${QMLPLUGIN_INCLUDES}
    ${liblomiri-private_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
)

foreach(source_file ${QMLPLUGIN_SRC})
    list(APPEND RELATIVE_QMLPLUGIN_SRC ../${source_file})
endforeach()

add_library(IntegratedLightDM-qml MODULE
    ${RELATIVE_QMLPLUGIN_SRC}
    )

target_link_libraries(IntegratedLightDM-qml
    integratedLightDM
    lomiri-private
    ${LIBUSERMETRICSOUTPUT_LDFLAGS}
    Qt5::DBus Qt5::Gui Qt5::Qml
    )

add_lomiri_plugin(IntegratedLightDM 0.1 LightDM/IntegratedLightDM TARGETS IntegratedLightDM-qml)

add_subdirectory(liblightdm)
