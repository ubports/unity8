file(GLOB INDICATOR_SERVICE_FILES
    ${CMAKE_CURRENT_SOURCE_DIR}/com.canonical.indicator.battery
    ${CMAKE_CURRENT_SOURCE_DIR}/com.canonical.indicator.messages
    ${CMAKE_CURRENT_SOURCE_DIR}/com.canonical.indicator.time
    ${CMAKE_CURRENT_SOURCE_DIR}/com.canonical.settings.network
    ${CMAKE_CURRENT_SOURCE_DIR}/com.canonical.settings.sound
)

# copy indicators files into build directory for shadow builds
add_custom_target(IndicatorsServiceFiles ALL
    COMMAND mkdir -p ${CMAKE_BINARY_DIR}/share/unity/indicators
    COMMAND cp ${INDICATOR_SERVICE_FILES} ${CMAKE_BINARY_DIR}/share/unity/indicators
    DEPENDS ${INDICATOR_SERVICE_FILES}
)

install(FILES ${INDICATOR_SERVICE_FILES}
        DESTINATION ${SHELL_APP_DIR}/unity/indicators
)
