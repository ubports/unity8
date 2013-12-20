# generate desktop file
configure_file(${SHELL_APP}.desktop.in ${CMAKE_CURRENT_BINARY_DIR}/${SHELL_APP}.desktop @ONLY)
configure_file(${SCOPE_TOOL}.desktop.in ${CMAKE_CURRENT_BINARY_DIR}/${SCOPE_TOOL}.desktop @ONLY)

# install desktop files
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${SHELL_APP}.desktop {CMAKE_CURRENT_BINARY_DIR}/${SCOPE_TOOL}.desktop
    DESTINATION ${CMAKE_INSTALL_DATADIR}/applications
    )
