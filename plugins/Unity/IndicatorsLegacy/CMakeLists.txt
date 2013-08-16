# export_qmlplugin macro
include(Plugins)

project(IndicatorsLegacyQml)

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
    ${CMAKE_SOURCE_DIR}/plugins/Unity/Indicators
)

set(IndicatorsLegacyQML_SOURCES
    ${CMAKE_SOURCE_DIR}/plugins/Unity/Indicators/indicators.h
    flatmenuproxymodel.cpp
    modelprinter.cpp
    plugin.cpp
)
add_definitions(-DUNITYINDICATORS_LIBRARY)

set(IndicatorsLegacyQML_RESOURCES
    resources/indicators.qrc
)

qt5_add_resources(IndicatorsLegacyQML_RESOURCES_RCC
    ${IndicatorsLegacyQML_RESOURCES}
)

add_library(IndicatorsLegacyQml SHARED
    ${IndicatorsLegacyQML_RESOURCES_RCC}
    ${IndicatorsLegacyQML_SOURCES}
)

target_link_libraries(IndicatorsLegacyQml
    ${QMENUMODEL_LDFLAGS}
)

qt5_use_modules(IndicatorsLegacyQml Core Qml Quick)

# export the qmltypes and plugin files
export_qmlplugin(Unity.IndicatorsLegacy 0.1 Unity/IndicatorsLegacy TARGETS IndicatorsLegacyQml)
