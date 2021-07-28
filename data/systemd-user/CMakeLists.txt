pkg_get_variable(SYSTEMD_USERUNITDIR systemd systemduserunitdir)

set(MODES full-greeter full-shell greeter shell)

foreach(MODE ${MODES})
    set(CONFLICT_UNITS "")
    foreach(OTHER_MODE ${MODES})
        if(NOT ${OTHER_MODE} STREQUAL ${MODE})
            set(CONFLICT_UNITS "${CONFLICT_UNITS} lomiri-${OTHER_MODE}.service")
        endif()
    endforeach()
    string(STRIP "${CONFLICT_UNITS}" CONFLICT_UNITS)

    configure_file(
        lomiri-MODE.service.in
        ${CMAKE_CURRENT_BINARY_DIR}/lomiri-${MODE}.service
        @ONLY
    )

    install(FILES
        ${CMAKE_CURRENT_BINARY_DIR}/lomiri-${MODE}.service
        DESTINATION ${SYSTEMD_USERUNITDIR}
    )
endforeach()

install(PROGRAMS
    lomiri-systemd-wrapper
    DESTINATION ${CMAKE_INSTALL_FULL_LIBEXECDIR}
)