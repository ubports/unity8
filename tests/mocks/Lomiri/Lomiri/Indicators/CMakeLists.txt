project(IndicatorsFakeQml)

find_package(Qt5Core REQUIRED)
find_package(Qt5Quick REQUIRED)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_SOURCE_DIR}/plugins/Lomiri/Indicators
    ${CMAKE_SOURCE_DIR}/tests/mocks/QMenuModel
)

set(IndicatorsFakeQml_SOURCES
    fakeplugin.cpp
    fakeindicatorsmodel.cpp
    fakelomirimenumodelcache.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Lomiri/Indicators/indicators.h
    ${CMAKE_SOURCE_DIR}/plugins/Lomiri/Indicators/menucontentactivator.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Lomiri/Indicators/modelprinter.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Lomiri/Indicators/sharedlomirimenumodel.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Lomiri/Indicators/lomirimenumodelcache.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Lomiri/Indicators/lomirimenumodelstack.cpp
)

add_library(IndicatorsFakeQml SHARED
    ${IndicatorsFakeQml_SOURCES}
)
add_definitions(-DLOMIRIINDICATORS_LIBRARY)

target_link_libraries(IndicatorsFakeQml
    QMenuModelQml
    Qt5::Core Qt5::Qml Qt5::Quick
)

set_target_properties(IndicatorsFakeQml PROPERTIES
    INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/${SHELL_INSTALL_QML}/mocks/QMenuModel"
)

add_lomiri_mock(Lomiri.Indicators 0.1 Lomiri/Indicators TARGETS IndicatorsFakeQml)
