# Creates target for copying and installing qmlfiles
#
# export_qmlfiles(plugin sub_path)
#
#
# Two targets will be created:
#   - plugin-qmlfiles - Copies the qml files (*.qml, *.js, qmldir) into the shadow build folder.

macro(export_qmlfiles PLUGIN PLUGIN_SUBPATH)

    file(GLOB QMLFILES
        *.qml
        *.js
        qmldir
    )

    # copy the qmldir file
    add_custom_target(${PLUGIN}-qmlfiles ALL
                        COMMAND cp ${QMLFILES} ${CMAKE_BINARY_DIR}/plugins/${PLUGIN_SUBPATH}
                        DEPENDS ${QMLFILES}
    )

    # install the qmlfiles file.
    install(FILES ${QMLFILES}
        DESTINATION ${SHELL_PRIVATE_LIBDIR}/qml/${PLUGIN_SUBPATH}
    )
endmacro(export_qmlfiles)


# Creates target for generating the qmltypes file for a plugin and installs plugin files
#
# export_qmlplugin(plugin version sub_path [TARGETS target1 [target2 ...]])
#
# TARGETS additional install targets (eg the plugin shared object)
#
# Two targets will be created:
#   - plugin-qmltypes - Generates the qmltypes file in the shadow build folder.

macro(export_qmlplugin PLUGIN VERSION PLUGIN_SUBPATH)
    set(multi_value_keywords TARGETS)
    cmake_parse_arguments(qmlplugin "" "" "${multi_value_keywords}" ${ARGN})

    # create the plugin.qmltypes file
    add_custom_target(${PLUGIN}-qmltypes ALL
        COMMAND qmlplugindump -notrelocatable ${PLUGIN} ${VERSION} ${CMAKE_BINARY_DIR}/plugins > ${CMAKE_BINARY_DIR}/plugins/${PLUGIN_SUBPATH}/plugin.qmltypes
    )
    add_dependencies(${PLUGIN}-qmltypes ${PLUGIN}-qmlfiles ${qmlplugin_TARGETS})

    # install the qmltypes file.
    install(FILES ${CMAKE_BINARY_DIR}/plugins/${PLUGIN_SUBPATH}/plugin.qmltypes
        DESTINATION ${SHELL_PRIVATE_LIBDIR}/qml/${PLUGIN_SUBPATH}
    )

    # install the additional targets
    install(TARGETS ${qmlplugin_TARGETS}
        DESTINATION ${SHELL_PRIVATE_LIBDIR}/qml/${PLUGIN_SUBPATH}
    )
endmacro(export_qmlplugin)
