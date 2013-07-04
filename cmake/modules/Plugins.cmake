# Creates targets for copying and installing qmlfiles and generating the qmltypes file for a plugin
#
# add_qml_test(plugin version plugin_export sub_path [DEPENDS target1 [target2 ...]])
#
# plugin_export folder where plugin will be found (plugins/modules/imports)
# TARGETS additional install targets (eg the plugin shared object)
#
# Two targets will be created:
#   - PluginName-qmlfiles - Copies the qml files (*.qml, *.js, qmldir) into the shadow build folder.
#   - PluginName-qmltypes - Generates the qmltypes file in the shadow build folder.


macro(export_qmlplugin PLUGIN VERSION PLUGIN_SUBPATH)
    set(multi_value_keywords TARGETS)
    cmake_parse_arguments(qmlplugin "" "" "${multi_value_keywords}" ${ARGN})

    file(GLOB QMLFILES
        *.qml
        *.js
        qmldir
    )

    # copy the qmldir file
    add_custom_target(${PLUGIN}-qmlfiles ALL
                        COMMAND cp ${QMLFILES} ${CMAKE_BINARY_DIR}/qml/${PLUGIN_SUBPATH}
                        DEPENDS ${QMLFILES}
    )

    # create the plugin.qmltypes file
    add_custom_target(${PLUGIN}-qmltypes ALL
        COMMAND qmlplugindump -notrelocatable ${PLUGIN} ${VERSION} ${CMAKE_BINARY_DIR}/qml > ${CMAKE_BINARY_DIR}/qml/${PLUGIN_SUBPATH}/plugin.qmltypes
    )
    add_dependencies(${PLUGIN}-qmltypes ${PLUGIN}-qmlfiles ${qmlplugin_TARGETS})

    # install the qmldir file.
    install(FILES ${QMLFILES}
        DESTINATION ${SHELL_APP_DIR}/qml/${PLUGIN_SUBPATH}
    )

    # install the qmltypes file.
    install(FILES ${CMAKE_BINARY_DIR}/qml/${PLUGIN_SUBPATH}/plugin.qmltypes
        DESTINATION ${SHELL_APP_DIR}/qml/${PLUGIN_SUBPATH}
    )

    # install the additional targets
    install(TARGETS ${qmlplugin_TARGETS}
        DESTINATION ${SHELL_APP_DIR}/qml/${PLUGIN_SUBPATH}
    )
endmacro(export_qmlplugin)