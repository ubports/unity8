add_definitions(-DTOP_SRCDIR="${CMAKE_SOURCE_DIR}")

add_library(MockAccountsService-qml MODULE
    AccountsService.cpp
    plugin.cpp
    )

qt5_use_modules(MockAccountsService-qml DBus Qml)

# copy files into build directory for shadow builds
file(COPY "${CMAKE_CURRENT_SOURCE_DIR}/qmldir"
    DESTINATION ${CMAKE_CURRENT_BINARY_DIR}
    )

install(TARGETS MockAccountsService-qml
    DESTINATION ${SHELL_INSTALL_QML}/mocks/AccountsService
    )

install(FILES qmldir
    DESTINATION ${SHELL_INSTALL_QML}/mocks/AccountsService
    )
