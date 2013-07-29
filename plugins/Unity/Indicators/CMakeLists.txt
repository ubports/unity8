# export_qmlplugin macro
include(Plugins)

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
    menucontentactivator.cpp
    modelprinter.cpp
    plugin.cpp
)
add_definitions(-DUNITYINDICATORS_LIBRARY)

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

target_link_libraries(IndicatorsQml
    ${QMENUMODEL_LDFLAGS}
)

qt5_use_modules(IndicatorsQml Core Qml Quick)

# export the qmltypes and plugin files
export_qmlplugin(Unity.Indicators 0.1 Unity/Indicators TARGETS IndicatorsQml)
