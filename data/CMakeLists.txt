# generate desktop files
configure_file(${SHELL_APP}.desktop.in ${CMAKE_CURRENT_BINARY_DIR}/${SHELL_APP}.desktop @ONLY)
configure_file(${INDICATORS_CLIENT_APP}.desktop.in ${CMAKE_CURRENT_BINARY_DIR}/${INDICATORS_CLIENT_APP}.desktop @ONLY)
configure_file(${GREETER_APP}.desktop.in ${CMAKE_CURRENT_BINARY_DIR}/${GREETER_APP}.desktop @ONLY)

# install desktop files
install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/${SHELL_APP}.desktop
    ${CMAKE_CURRENT_BINARY_DIR}/${INDICATORS_CLIENT_APP}.desktop
    DESTINATION ${CMAKE_INSTALL_DATADIR}/applications
    )

install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/${GREETER_APP}.desktop
    DESTINATION ${CMAKE_INSTALL_DATADIR}/lightdm/greeters
    )

install(FILES
    51-lomiri-greeter.conf
    DESTINATION ${CMAKE_INSTALL_DATADIR}/lightdm/lightdm.conf.d
    )

add_custom_target(pkgversion ALL COMMAND dpkg-parsechangelog -l${CMAKE_SOURCE_DIR}/debian/changelog --show-field version > ${CMAKE_CURRENT_BINARY_DIR}/version)

install(FILES com.lomiri.Shell.gschema.xml DESTINATION ${CMAKE_INSTALL_DATADIR}/glib-2.0/schemas)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/version DESTINATION ${CMAKE_INSTALL_LOCALSTATEDIR}/lib/lomiri)

add_subdirectory(systemd-user)
