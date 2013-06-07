set(INDICATORCLIENT_POWER_SRC
    indicatorclient_power.cpp
)

qt5_add_resources(INDICATORCLIENT_POWER_RESOURCES_RCC
    indicatorclient_power.qrc
)

add_library(indicatorclient_power STATIC
    ${INDICATORCLIENT_POWER_RESOURCES_RCC}
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

