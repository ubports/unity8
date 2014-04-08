# copy files into build directory for shadow builds
add_custom_target(UbuntuThumbnailerQmlDirFile ALL
    COMMAND cp "${CMAKE_CURRENT_SOURCE_DIR}/qmldir" ${CMAKE_CURRENT_BINARY_DIR}
    DEPENDS qmldir
)

install(FILES qmldir DESTINATION ${SHELL_INSTALL_QML}/mocks/Ubuntu/Thumbnailer)
