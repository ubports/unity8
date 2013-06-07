set(INDICATORCLIENT_DATETIME_SRC
    indicatorclient_datetime.cpp
)

qt5_add_resources(INDICATORCLIENT_DATETIME_RESOURCES_RCC
    indicatorclient_datetime.qrc
)

add_library(indicatorclient_datetime STATIC
    ${INDICATORCLIENT_DATETIME_RESOURCES_RCC}
    ${INDICATORCLIENT_DATETIME_SRC}
)

qt5_use_modules(indicatorclient_datetime Core Qml)

set_target_properties(indicatorclient_datetime PROPERTIES COMPILE_FLAGS -fPIC)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${QMENUMODEL_INCLUDE_DIRS}
    ${indicatorclient_common_SOURCE_DIR}
    ${IndicatorsClientQml_SOURCE_DIR}
)

target_link_libraries(indicatorclient_datetime
    indicatorclient_common
    ${QMENUMODEL_LDFLAGS}
)

set(INDICATOR_FILES
    ${CMAKE_CURRENT_SOURCE_DIR}/indicator-datetime.indicator
)

# copy indicators file into build directory for shadow builds
file(COPY ${INDICATOR_FILES}
    DESTINATION ${CMAKE_BINARY_DIR}/share/unity/indicators
)

# install indicator file
install(FILES ${INDICATOR_FILES}
    DESTINATION ${CMAKE_INSTALL_DATADIR}/unity/indicators
)
