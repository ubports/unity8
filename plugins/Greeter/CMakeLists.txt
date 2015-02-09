macro(add_unity8_greeter_plugin PLUGIN VERSION PATH)
    export_qmlfiles(${PLUGIN} ${PATH} DESTINATION ${SHELL_INSTALL_QML}/Greeter TARGET_PREFIX Greeter ${ARGN})
    export_qmlplugin(${PLUGIN} ${VERSION} ${PATH} DESTINATION ${SHELL_INSTALL_QML}/Greeter TARGET_PREFIX Greeter ${ARGN})
endmacro()

add_subdirectory(Unity)
