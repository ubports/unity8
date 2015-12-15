# generate desktop files
configure_file(${SHELL_APP}.desktop.in ${CMAKE_CURRENT_BINARY_DIR}/${SHELL_APP}.desktop @ONLY)
configure_file(${DASH_APP}.desktop.in ${CMAKE_CURRENT_BINARY_DIR}/${DASH_APP}.desktop @ONLY)
configure_file(${INDICATORS_CLIENT_APP}.desktop.in ${CMAKE_CURRENT_BINARY_DIR}/${INDICATORS_CLIENT_APP}.desktop @ONLY)

# install desktop files
install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/${SHELL_APP}.desktop
    ${CMAKE_CURRENT_BINARY_DIR}/${DASH_APP}.desktop
    ${CMAKE_CURRENT_BINARY_DIR}/${INDICATORS_CLIENT_APP}.desktop
    DESTINATION ${CMAKE_INSTALL_DATADIR}/applications
    )

# install dash icon
install(FILES
    ${CMAKE_CURRENT_SOURCE_DIR}/${DASH_APP}.png
    DESTINATION ${SHELL_APP_DIR}/Dash/
    )

add_custom_target(pkgversion ALL COMMAND dpkg-parsechangelog -l${CMAKE_SOURCE_DIR}/debian/changelog --show-field version > ${CMAKE_CURRENT_BINARY_DIR}/version)

install(FILES com.canonical.Unity8.gschema.xml DESTINATION ${CMAKE_INSTALL_DATADIR}/glib-2.0/schemas)
install(FILES unity8-dash.url-dispatcher DESTINATION ${CMAKE_INSTALL_DATADIR}/url-dispatcher/urls)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/version DESTINATION ${CMAKE_INSTALL_LOCALSTATEDIR}/lib/unity8)
