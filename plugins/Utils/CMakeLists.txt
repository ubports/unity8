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

# copy qmldir file into build directory for shadow builds
file(COPY "${CMAKE_CURRENT_SOURCE_DIR}/qmldir"
    DESTINATION ${CMAKE_CURRENT_BINARY_DIR}
    )

# create the Utils.qmltypes file
add_custom_target(Utils-qmltypes ALL
    COMMAND qmlplugindump -notrelocatable Utils 0.1 ${CMAKE_BINARY_DIR}/plugins > ${CMAKE_CURRENT_BINARY_DIR}/Utils.qmltypes
)
add_dependencies(Utils-qmltypes Utils-qml)

install(TARGETS Utils-qml
    DESTINATION ${SHELL_APP_DIR}/plugins/Utils
    )

install(FILES qmldir
    DESTINATION ${SHELL_APP_DIR}/plugins/Utils
    )

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/Utils.qmltypes
    DESTINATION ${SHELL_APP_DIR}/plugins/Utils
    )
