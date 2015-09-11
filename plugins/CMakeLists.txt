include(QmlPlugins)

# Set up and install a plugin for unity8.
#
# add_unity8_plugin(plugin version path
#     [...]  # See export_qmlfiles and export_qmlplugin documentation for more options
# )

macro(add_unity8_plugin PLUGIN VERSION PATH)
    export_qmlfiles(${PLUGIN} ${PATH} DESTINATION ${SHELL_INSTALL_QML} ${ARGN})
    export_qmlplugin(${PLUGIN} ${VERSION} ${PATH} DESTINATION ${SHELL_INSTALL_QML} ${ARGN})
endmacro()

add_subdirectory(AccountsService)
add_subdirectory(GlobalShortcut)
add_subdirectory(Greeter)
add_subdirectory(IntegratedLightDM)
add_subdirectory(Lights)
add_subdirectory(Dash)
add_subdirectory(Powerd)
add_subdirectory(SessionBroadcast)
add_subdirectory(ScreenGrabber)
add_subdirectory(Ubuntu)
add_subdirectory(Unity)
add_subdirectory(Utils)
add_subdirectory(Wizard)
