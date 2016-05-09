add_executable(${SCOPE_TOOL}
    scopetool.cpp
    registry-tracker.cpp
    ../src/UnixSignalHandler.cpp
    )

qt5_use_modules(${SCOPE_TOOL} Qml Quick)

# install binaries
install(TARGETS ${SCOPE_TOOL}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    )

install(FILES unlock-device DESTINATION ${SHELL_APP_DIR})
