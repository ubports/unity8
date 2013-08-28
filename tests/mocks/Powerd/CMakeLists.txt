add_definitions(-DSM_BUSNAME=sessionBus)

add_library(MockPowerd-qml MODULE
    plugin.cpp
    Powerd.cpp
    )

qt5_use_modules(MockPowerd-qml Qml)

# copy qmldir file into build directory for shadow builds
file(COPY "${CMAKE_CURRENT_SOURCE_DIR}/qmldir"
    DESTINATION ${CMAKE_CURRENT_BINARY_DIR}
    )

install(TARGETS MockPowerd-qml
    DESTINATION ${SHELL_PRIVATE_LIBDIR}/qml/mocks/Powerd
    )

install(FILES qmldir
    DESTINATION ${SHELL_PRIVATE_LIBDIR}/qml/mocks/Powerd
    )
