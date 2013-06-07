set(INDICATORCLIENT_MESSAGING_SRC
    indicatorclient_messaging.cpp
)

add_library(indicatorclient_messaging STATIC
    ${INDICATORCLIENT_MESSAGING_SRC}
)

qt5_use_modules(indicatorclient_messaging Core Qml)

set_target_properties(indicatorclient_messaging PROPERTIES COMPILE_FLAGS -fPIC)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${indicatorclient_common_SOURCE_DIR}
    ${IndicatorsClientQml_SOURCE_DIR}
)

target_link_libraries(indicatorclient_messaging
    indicatorclient_common
    ${QMENUMODEL_LDFLAGS}
)

set(INDICATOR_FILES
    ${CMAKE_CURRENT_SOURCE_DIR}/indicator-messaging.indicator
)

# copy indicators file into build directory for shadow builds
file(COPY ${INDICATOR_FILES}
    DESTINATION ${CMAKE_BINARY_DIR}/share/unity/indicators
)

# install indicator file
install(FILES ${INDICATOR_FILES}
    DESTINATION ${CMAKE_INSTALL_DATADIR}/unity/indicators
)
