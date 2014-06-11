add_library(MockSessionManager-qml MODULE
    plugin.cpp
    SessionManager.cpp
    )

qt5_use_modules(MockSessionManager-qml Qml)

# copy qmldir file into build directory for shadow builds
file(COPY "${CMAKE_CURRENT_SOURCE_DIR}/qmldir"
    DESTINATION ${CMAKE_CURRENT_BINARY_DIR}
    )

install(TARGETS MockSessionManager-qml
    DESTINATION ${SHELL_INSTALL_QML}/mocks/SessionManager
    )

install(FILES qmldir
    DESTINATION ${SHELL_INSTALL_QML}/mocks/SessionManager
    )
