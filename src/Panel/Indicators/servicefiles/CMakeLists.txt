set(INDICATOR_FILES
    ${CMAKE_CURRENT_SOURCE_DIR}/com.canonical.indicator.battery
    ${CMAKE_CURRENT_SOURCE_DIR}/com.canonical.indicator.messages
    ${CMAKE_CURRENT_SOURCE_DIR}/com.canonical.indicator.time
    ${CMAKE_CURRENT_SOURCE_DIR}/com.canonical.settings.network
    ${CMAKE_CURRENT_SOURCE_DIR}/com.canonical.settings.sound
)

# copy indicators file into build directory for shadow builds
file(COPY ${INDICATOR_FILES}
    DESTINATION ${CMAKE_BINARY_DIR}/share/unity/indicators
)

# install indicator file
install(FILES ${INDICATOR_FILES}
    DESTINATION ${SHELL_APP_DIR}/unity/indicators
)
