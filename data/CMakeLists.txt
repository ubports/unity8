# generate desktop file
configure_file(${SHELL_APP}.desktop.in ${CMAKE_CURRENT_BINARY_DIR}/${SHELL_APP}.desktop @ONLY)
configure_file(${GREETER_APP}.desktop.in ${CMAKE_CURRENT_BINARY_DIR}/${GREETER_APP}.desktop @ONLY)
configure_file(${SCOPE_TOOL}.desktop.in ${CMAKE_CURRENT_BINARY_DIR}/${SCOPE_TOOL}.desktop @ONLY)

# install desktop files
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${SHELL_APP}.desktop ${CMAKE_CURRENT_BINARY_DIR}/${SCOPE_TOOL}.desktop
    DESTINATION ${CMAKE_INSTALL_DATADIR}/applications
    )
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${GREETER_APP}.desktop
    DESTINATION ${CMAKE_INSTALL_DATADIR}/lightdm/greeters
    )
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/51-${GREETER_APP}.conf
    DESTINATION ${CMAKE_INSTALL_DATADIR}/lightdm/lightdm.conf.d
    )
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/${GREETER_APP}-wrapper
    DESTINATION ${CMAKE_INSTALL_BINDIR}
    )
