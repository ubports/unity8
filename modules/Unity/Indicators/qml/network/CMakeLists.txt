file(GLOB IndicatorsNetwork_QMLFILES
    *.qml
)

# copy qmldir file into build directory for shadow builds
file(COPY "${CMAKE_CURRENT_SOURCE_DIR}/qmldir"
    DESTINATION ${CMAKE_BINARY_DIR}/modules/Unity/Indicators/Network
)

# copy qmldir file into build directory for shadow builds
file(COPY ${IndicatorsNetwork_QMLFILES}
    DESTINATION ${CMAKE_BINARY_DIR}/modules/Unity/Indicators/Network
)

install(FILES qmldir
        DESTINATION ${SHELL_APP_DIR}/modules/Unity/Indicators/Network
)

install(FILES ${IndicatorsNetwork_QMLFILES}
        DESTINATION ${SHELL_APP_DIR}/modules/Unity/Indicators/Network
)
