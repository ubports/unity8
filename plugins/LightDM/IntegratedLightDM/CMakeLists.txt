set(PLUGIN_CLASSNAME "IntegratedLightDM")

# Written to source dir as thats where add_unity8_plugin expects it
configure_file(../qmldir.in ${CMAKE_CURRENT_SOURCE_DIR}/qmldir)

add_definitions(-DINTEGRATED_LIGHTDM)

foreach(include_directory ${QMLPLUGIN_INCLUDES})
        list(APPEND RELATIVE_QMLPLUGIN_INCLUDES ../${include_directory})
endforeach()

include_directories(
    ${QMLPLUGIN_INCLUDES}
    ${libunity8-private_SOURCE_DIR}
 ${CMAKE_SOURCE_DIR}/tests/mocks/LightDM/IntegratedLightDM
 ${CMAKE_BINARY_DIR}/tests/mocks/LightDM/IntegratedLightDM
)

foreach(source_file ${QMLPLUGIN_SRC})
    list(APPEND RELATIVE_QMLPLUGIN_SRC ../${source_file})
endforeach()

add_library(IntegratedLightDM-qml MODULE
    ${RELATIVE_QMLPLUGIN_SRC}
    )

target_link_libraries(IntegratedLightDM-qml
    integratedLightDM
    unity8-private
    ${LIBUSERMETRICSOUTPUT_LDFLAGS}
    )

qt5_use_modules(IntegratedLightDM-qml DBus Gui Qml)
add_unity8_plugin(IntegratedLightDM 0.1 LightDM/IntegratedLightDM TARGETS IntegratedLightDM-qml)

add_subdirectory(liblightdm)
