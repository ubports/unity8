file(GLOB IndicatorsNetwork_QMLFILES
    *.qml
    *.js
    qmldir
)

# copy qml & qmldir files into build directory for shadow builds
add_custom_target(UnityIndicatorsNetworkQmlFiles ALL
    COMMAND cp ${IndicatorsNetwork_QMLFILES} ${CMAKE_BINARY_DIR}/modules/Unity/Indicators/Network
    DEPENDS ${IndicatorsNetwork_QMLFILES}
)

install(FILES ${IndicatorsNetwork_QMLFILES}
        DESTINATION ${SHELL_APP_DIR}/modules/Unity/Indicators/Network
)
