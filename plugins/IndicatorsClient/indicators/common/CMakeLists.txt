project(indicatorclient_common)

set(INDICATORCLIENT_COMMON_SRC
    indicatorclient_common.cpp
)

add_library(indicatorclient_common STATIC
    ${INDICATORCLIENT_COMMON_RESOURCES_RCC}
    ${INDICATORCLIENT_COMMON_SRC}
)

qt5_use_modules(indicatorclient_common Core Qml)

set_target_properties(indicatorclient_common PROPERTIES COMPILE_FLAGS -fPIC)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${QMENUMODEL_INCLUDE_DIRS}
    ${IndicatorsClientQml_SOURCE_DIR}
)

target_link_libraries(indicatorclient_common
    ${QMENUMODEL_LDFLAGS}
)
