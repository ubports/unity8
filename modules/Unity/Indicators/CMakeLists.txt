project(IndicatorsQml)

pkg_check_modules(QMENUMODEL REQUIRED qmenumodel)
find_package(Qt5Core REQUIRED)
find_package(Qt5Quick REQUIRED)

add_subdirectory(qml)
add_subdirectory(Messaging)
add_subdirectory(Network)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
    ${QMENUMODEL_INCLUDE_DIRS}
)

set(IndicatorsQML_SOURCES
    flatmenuproxymodel.cpp
    indicator.cpp
    indicators.h
    indicatorsmanager.cpp
    indicatorsmodel.cpp
    plugin.cpp
)

set(IndicatorsQML_RESOURCES
    resources/indicators.qrc
)

qt5_add_resources(IndicatorsQML_RESOURCES_RCC
    ${IndicatorsQML_RESOURCES}
)

add_library(IndicatorsQml SHARED
    ${IndicatorsQML_RESOURCES_RCC}
    ${IndicatorsQML_SOURCES}
)
# Because this is an internal support library, we want
# to expose all symbols in it. Consider changing this
# either to a static library or just using the
# files directly in targets.
set_target_properties(IndicatorsQml PROPERTIES COMPILE_FLAGS -fvisibility=default)

target_link_libraries(IndicatorsQml
    ${QMENUMODEL_LDFLAGS}
)

qt5_use_modules(IndicatorsQml Core Qml Quick)

install(TARGETS IndicatorsQml
    DESTINATION ${SHELL_APP_DIR}/modules/Unity/Indicators
    )
