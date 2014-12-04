include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
    ${Qt5Gui_PRIVATE_INCLUDE_DIRS}
)

set(QMLPLUGIN_SRC
    qsortfilterproxymodelqml.cpp
    plugin.cpp
    system.cpp
    )

add_library(WizardUtils-qml SHARED
    ${QMLPLUGIN_SRC}
    )

# Because this is an internal support library, we want
# to expose all symbols in it. Consider changing this
# either to a static library or just using the
# files directly in targets.
set_target_properties(WizardUtils-qml PROPERTIES COMPILE_FLAGS -fvisibility=default)

qt5_use_modules(WizardUtils-qml DBus Qml Quick)

set(PLUG_DIR ${PLUGIN_PRIVATE_MODULE_DIR}/Ubuntu/SystemSettings/Wizard/Utils)
install(FILES qmldir DESTINATION ${PLUG_DIR})
install(TARGETS WizardUtils-qml DESTINATION ${PLUG_DIR})
