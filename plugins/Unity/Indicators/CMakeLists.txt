project(IndicatorsQml)

find_package(Qt5Core REQUIRED)
find_package(Qt5Quick REQUIRED)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
    ${GLIB_INCLUDE_DIRS}
    ${GIO_INCLUDE_DIRS}
    ${QMENUMODEL_INCLUDE_DIRS}
)

set(IndicatorsQML_SOURCES
    actionrootstate.cpp
    indicator.cpp
    indicators.h
    indicatorsmanager.cpp
    indicatorsmodel.cpp
    menucontentactivator.cpp
    modelactionrootstate.cpp
    modelprinter.cpp
    plugin.cpp
    rootstateparser.cpp
    sharedunitymenumodel.cpp
    unitymenumodelcache.cpp
    unitymenumodelstack.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Unity/Platform/platform.cpp
)
add_definitions(-DUNITYINDICATORS_LIBRARY)

add_library(IndicatorsQml SHARED
    ${IndicatorsQML_SOURCES}
)

target_link_libraries(IndicatorsQml
    ${GLIB_LIBRARIES}
    ${GIO_LIBRARIES}
    ${QMENUMODEL_LDFLAGS}
)

qt5_use_modules(IndicatorsQml Core Qml Quick DBus)

add_unity8_plugin(Unity.Indicators 0.1 Unity/Indicators TARGETS IndicatorsQml)
