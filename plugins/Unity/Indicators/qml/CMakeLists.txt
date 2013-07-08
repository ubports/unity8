file(GLOB Indicators_QMLFILES
    *.qml
    qmldir
)

# copy qml & qmldir files into build directory for shadow builds
add_custom_target(UnityIndicatorsQmlFiles ALL
    COMMAND cp ${Indicators_QMLFILES} ${CMAKE_BINARY_DIR}/plugins/Unity/Indicators
    DEPENDS ${Indicators_QMLFILES}
)

install(FILES ${Indicators_QMLFILES}
        DESTINATION ${SHELL_PRIVATE_LIBDIR}/qml/Unity/Indicators
)
