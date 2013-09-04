add_definitions(-DTOP_SRCDIR="${CMAKE_SOURCE_DIR}")

add_library(MockAccountsService-qml MODULE
    AccountsBindings.cpp
    plugin.cpp
    )

qt5_use_modules(MockAccountsService-qml DBus Qml)

# copy files into build directory for shadow builds
file(COPY "${CMAKE_CURRENT_SOURCE_DIR}/qmldir"
    DESTINATION ${CMAKE_CURRENT_BINARY_DIR}
    )

install(TARGETS MockAccountsService-qml
    DESTINATION ${SHELL_PRIVATE_LIBDIR}/qml/mocks/AccountsService
    )

install(FILES qmldir
    DESTINATION ${SHELL_PRIVATE_LIBDIR}/qml/mocks/AccountsService
    )
