set(INDICATOR_FILES
    ${CMAKE_CURRENT_SOURCE_DIR}/indicator-datetime.indicator
    ${CMAKE_CURRENT_SOURCE_DIR}/indicator-messaging.indicator
    ${CMAKE_CURRENT_SOURCE_DIR}/indicator-network.indicator
    ${CMAKE_CURRENT_SOURCE_DIR}/indicator-power.indicator
    ${CMAKE_CURRENT_SOURCE_DIR}/indicator-sound.indicator
)

# copy indicators file into build directory for shadow builds
file(COPY ${INDICATOR_FILES}
    DESTINATION ${CMAKE_BINARY_DIR}/share/unity/indicators
)

# install indicator file
install(FILES ${INDICATOR_FILES}
    DESTINATION ${CMAKE_INSTALL_DATADIR}/unity/indicators
)
