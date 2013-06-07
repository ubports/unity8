set(INDICATORCLIENT_POWER_SRC
    indicatorclient_power.cpp
)

add_library(indicatorclient_power STATIC
    ${INDICATORCLIENT_POWER_SRC}
)

qt5_use_modules(indicatorclient_power Core Qml)

set_target_properties(indicatorclient_power PROPERTIES COMPILE_FLAGS -fPIC)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${indicatorclient_common_SOURCE_DIR}
    ${IndicatorsClientQml_SOURCE_DIR}
)

target_link_libraries(indicatorclient_power
    indicatorclient_common
    ${QMENUMODEL_LDFLAGS}
)

set(INDICATOR_FILES
    ${CMAKE_CURRENT_SOURCE_DIR}/indicator-power.indicator
)

# copy indicators file into build directory for shadow builds
file(COPY ${INDICATOR_FILES}
    DESTINATION ${CMAKE_BINARY_DIR}/share/unity/indicators
)

# install indicator file
install(FILES ${INDICATOR_FILES}
    DESTINATION ${CMAKE_INSTALL_DATADIR}/unity/indicators
)
