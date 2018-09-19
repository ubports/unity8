add_executable(${SCOPE_TOOL}
    scopetool.cpp
    registry-tracker.cpp
    ../../src/UnixSignalHandler.cpp
    )

target_link_libraries(${SCOPE_TOOL} Qt5::Qml Qt5::Quick)

# install binaries
install(TARGETS ${SCOPE_TOOL}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    )
