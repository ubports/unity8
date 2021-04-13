project(IndicatorsQml)

find_package(Qt5Core REQUIRED)
find_package(Qt5Quick REQUIRED)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
)

include_directories(
    SYSTEM
    ${GLIB_INCLUDE_DIRS}
)
include_directories(
    SYSTEM
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
    sharedlomirimenumodel.cpp
    lomirimenumodelcache.cpp
    lomirimenumodelstack.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Lomiri/Platform/platform.cpp
)
add_definitions(-DLOMIRIINDICATORS_LIBRARY)

add_library(IndicatorsQml SHARED
    ${IndicatorsQML_SOURCES}
)

target_link_libraries(IndicatorsQml
    ${GLIB_LIBRARIES}
    ${GIO_LIBRARIES}
    ${QMENUMODEL_LDFLAGS}
    Qt5::Core Qt5::Qml Qt5::Quick Qt5::DBus
)

add_lomiri_plugin(Lomiri.Indicators 0.1 Lomiri/Indicators TARGETS IndicatorsQml)
