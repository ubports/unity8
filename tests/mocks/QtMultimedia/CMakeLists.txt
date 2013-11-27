add_library(QtMultimedia-qml MODULE
    plugin.cpp
    audio.cpp
    )

qt5_use_modules(QtMultimedia-qml Qml)

# copy qmldir file into build directory for shadow builds
file(COPY "${CMAKE_CURRENT_SOURCE_DIR}/qmldir"
    DESTINATION ${CMAKE_CURRENT_BINARY_DIR}
    )

install(TARGETS QtMultimedia-qml
    DESTINATION ${SHELL_INSTALL_QML}/mocks/QtMultimedia
    )

install(FILES qmldir
    DESTINATION ${SHELL_INSTALL_QML}/mocks/QtMultimedia
    )
