# generate desktop file
configure_file(${SHELL_APP}.desktop.in ${CMAKE_CURRENT_BINARY_DIR}/${SHELL_APP}.desktop @ONLY)

# install desktop file
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${SHELL_APP}.desktop
    DESTINATION ${CMAKE_INSTALL_DATADIR}/applications
    )
