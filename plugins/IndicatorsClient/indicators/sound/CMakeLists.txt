set(INDICATORCLIENT_SOUND_SRC
    indicatorclient_sound.cpp
)

set(INDICATORCLIENT_SOUND_RESOURCES
    indicatorclient_sound.qrc
)

qt5_add_resources(INDICATORCLIENT_SOUND_RESOURCES_RCC
    ${INDICATORCLIENT_SOUND_RESOURCES}
)

add_library(indicatorclient_sound STATIC
    ${INDICATORCLIENT_SOUND_RESOURCES_RCC}
    ${INDICATORCLIENT_SOUND_SRC}
)

qt5_use_modules(indicatorclient_sound Core Qml)

set_target_properties(indicatorclient_sound PROPERTIES COMPILE_FLAGS -fPIC)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${indicatorclient_common_SOURCE_DIR}
    ${IndicatorsClientQml_SOURCE_DIR}
)

target_link_libraries(indicatorclient_sound
    indicatorclient_common
    ${QMENUMODEL_LDFLAGS}
)

