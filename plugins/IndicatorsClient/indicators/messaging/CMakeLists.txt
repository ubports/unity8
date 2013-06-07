set(INDICATORCLIENT_MESSAGING_SRC
    indicatorclient_messaging.cpp
)

qt5_add_resources(INDICATORCLIENT_MESSAGING_RESOURCES_RCC
    indicatorclient_messaging.qrc
)

add_library(indicatorclient_messaging STATIC
    ${INDICATORCLIENT_MESSAGING_RESOURCES_RCC}
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

