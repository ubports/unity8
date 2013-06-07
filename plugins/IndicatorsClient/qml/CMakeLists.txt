file(GLOB IndicatorsClient_QMLFILES
    *.qml
)

# copy qmldir file into build directory for shadow builds
file(COPY "${CMAKE_CURRENT_SOURCE_DIR}/qmldir"
    DESTINATION ${CMAKE_BINARY_DIR}/plugins/IndicatorsClient
)

# copy qmldir file into build directory for shadow builds
file(COPY ${IndicatorsClient_QMLFILES}
    DESTINATION ${CMAKE_BINARY_DIR}/plugins/IndicatorsClient
)

install(FILES qmldir
        DESTINATION ${SHELL_APP_DIR}/plugins/IndicatorsClient
)

install(FILES ${IndicatorsClient_QMLFILES}
        DESTINATION ${SHELL_APP_DIR}/plugins/IndicatorsClient/Network
)

add_subdirectory(messaging)
add_subdirectory(network)
