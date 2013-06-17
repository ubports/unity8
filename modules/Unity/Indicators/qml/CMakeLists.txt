file(GLOB Indicators_QMLFILES
    *.qml
)

# copy qmldir file into build directory for shadow builds
file(COPY "${CMAKE_CURRENT_SOURCE_DIR}/qmldir"
    DESTINATION ${CMAKE_BINARY_DIR}/modules/Unity/Indicators
)

# copy qmldir file into build directory for shadow builds
file(COPY ${Indicators_QMLFILES}
    DESTINATION ${CMAKE_BINARY_DIR}/modules/Unity/Indicators
)

install(FILES qmldir
        DESTINATION ${SHELL_APP_DIR}/modules/Unity/Indicators
)

install(FILES ${Indicators_QMLFILES}
        DESTINATION ${SHELL_APP_DIR}/modules/Unity/Indicators/Network
)

add_subdirectory(messaging)
add_subdirectory(network)
