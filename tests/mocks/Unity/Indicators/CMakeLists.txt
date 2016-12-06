project(IndicatorsFakeQml)

find_package(Qt5Core REQUIRED)
find_package(Qt5Quick REQUIRED)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_SOURCE_DIR}/plugins/Unity/Indicators
    ${CMAKE_SOURCE_DIR}/tests/mocks/QMenuModel
)

set(IndicatorsFakeQml_SOURCES
    fakeplugin.cpp
    fakeindicatorsmodel.cpp
    fakeunitymenumodelcache.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Unity/Indicators/indicators.h
    ${CMAKE_SOURCE_DIR}/plugins/Unity/Indicators/menucontentactivator.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Unity/Indicators/modelprinter.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Unity/Indicators/sharedunitymenumodel.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Unity/Indicators/unitymenumodelcache.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Unity/Indicators/unitymenumodelstack.cpp
)

add_library(IndicatorsFakeQml SHARED
    ${IndicatorsFakeQml_SOURCES}
)
add_definitions(-DUNITYINDICATORS_LIBRARY)

target_link_libraries(IndicatorsFakeQml
    QMenuModelQml
)

set_target_properties(IndicatorsFakeQml PROPERTIES
    INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/${SHELL_INSTALL_QML}/mocks/QMenuModel"
)

qt5_use_modules(IndicatorsFakeQml Core Qml Quick)

add_unity8_mock(Unity.Indicators 0.1 Unity/Indicators TARGETS IndicatorsFakeQml)
