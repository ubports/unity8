include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
    ${Qt5Gui_PRIVATE_INCLUDE_DIRS}
)

set(QMLPLUGIN_SRC
    qlimitproxymodelqml.cpp
    qsortfilterproxymodelqml.cpp
    ubuntuwindow.cpp
    plugin.cpp
    )

add_library(Utils-qml SHARED
    ${QMLPLUGIN_SRC}
    )
# Because this is an internal support library, we want
# to expose all symbols in it. Consider changing this
# either to a static library or just using the
# files directly in targets.
set_target_properties(Utils-qml PROPERTIES COMPILE_FLAGS -fvisibility=default)

qt5_use_modules(Utils-qml Qml Quick)

# export the qmldir and qmltypes files
export_qmlplugin(Utils 0.1 Utils TARGETS Utils-qml)
