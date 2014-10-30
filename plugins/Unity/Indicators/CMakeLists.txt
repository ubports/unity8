project(IndicatorsQml)

pkg_check_modules(GLIB REQUIRED glib-2.0>=2.32)
pkg_check_modules(GIO REQUIRED gio-2.0>=2.32)
pkg_check_modules(QMENUMODEL REQUIRED qmenumodel)

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
    indicator.cpp
    indicators.h
    indicatorsmanager.cpp
    indicatorsmodel.cpp
    menucontentactivator.cpp
    modelprinter.cpp
    plugin.cpp
    rootactionstate.cpp
    sharedunitymenumodel.cpp
    unitymenumodelcache.cpp
    unitymenumodelstack.cpp
    visibleindicatorsmodel.cpp
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

qt5_use_modules(IndicatorsQml Core Qml Quick)

add_unity8_plugin(Unity.Indicators 0.1 Unity/Indicators TARGETS IndicatorsQml)
