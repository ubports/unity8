file(GLOB IndicatorsMessaging_QMLFILES
    *.qml
    *.js
)

# copy qmldir file into build directory for shadow builds
file(COPY "${CMAKE_CURRENT_SOURCE_DIR}/qmldir"
    DESTINATION ${CMAKE_BINARY_DIR}/modules/Unity/Indicators/Messaging
)

# copy qmldir file into build directory for shadow builds
file(COPY ${IndicatorsMessaging_QMLFILES}
    DESTINATION ${CMAKE_BINARY_DIR}/modules/Unity/Indicators/Messaging
)

install(FILES qmldir
        DESTINATION ${SHELL_APP_DIR}/modules/Unity/Indicators/Messaging
)

install(FILES ${IndicatorsMessaging_QMLFILES}
        DESTINATION ${SHELL_APP_DIR}/modules/Unity/Indicators/Messaging
)
