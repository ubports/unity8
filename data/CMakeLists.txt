# generate desktop files
configure_file(${SHELL_APP}.desktop.in ${CMAKE_CURRENT_BINARY_DIR}/${SHELL_APP}.desktop @ONLY)
configure_file(${DASH_APP}.desktop.in ${CMAKE_CURRENT_BINARY_DIR}/${DASH_APP}.desktop @ONLY)

# install desktop files
install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/${SHELL_APP}.desktop
    ${CMAKE_CURRENT_BINARY_DIR}/${DASH_APP}.desktop
    DESTINATION ${CMAKE_INSTALL_DATADIR}/applications
    )
