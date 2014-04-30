# generate desktop file
configure_file(${SHELL_APP}.desktop.in ${CMAKE_CURRENT_BINARY_DIR}/${SHELL_APP}.desktop @ONLY)
configure_file(${GREETER_APP}.desktop.in ${CMAKE_CURRENT_BINARY_DIR}/${GREETER_APP}.desktop @ONLY)

# install desktop files
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${SHELL_APP}.desktop
    DESTINATION ${CMAKE_INSTALL_DATADIR}/applications
    )
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${GREETER_APP}.desktop
    DESTINATION ${CMAKE_INSTALL_DATADIR}/lightdm/greeters
    )
install(FILES 51-${GREETER_APP}.conf
    DESTINATION ${CMAKE_INSTALL_DATADIR}/lightdm/lightdm.conf.d
    )
install(FILES ${GREETER_APP}-wrapper
    DESTINATION ${CMAKE_INSTALL_BINDIR}
    )
install(FILES unity8-greeter-init.conf unity8-greeter-ofono.conf
    DESTINATION ${CMAKE_INSTALL_DATADIR}/upstart/sessions
    )
