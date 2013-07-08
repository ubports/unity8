file(GLOB IndicatorsMessaging_QMLFILES
    *.qml
    *.js
    qmldir
)

# copy qml & qmldir files into build directory for shadow builds
add_custom_target(UnityIndicatorsMessagingQmlFiles ALL
    COMMAND cp ${IndicatorsMessaging_QMLFILES} ${CMAKE_BINARY_DIR}/plugins/Unity/Indicators/Messaging
    DEPENDS ${IndicatorsMessaging_QMLFILES}
)

install(FILES ${IndicatorsMessaging_QMLFILES}
        DESTINATION ${SHELL_PRIVATE_LIBDIR}/qml/Unity/Indicators/Messaging
)
