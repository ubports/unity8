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
    ${CMAKE_SOURCE_DIR}/plugins/Unity/Indicators/indicators.h
    ${CMAKE_SOURCE_DIR}/plugins/Unity/Indicators/menucontentactivator.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Unity/Indicators/unitymenumodelstack.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Unity/Indicators/visibleindicatorsmodel.cpp
    fakeindicatorsmodel.cpp
)

set(IndicatorsFakeQml_RESOURCES
    indicators_fake.qrc
)

qt5_add_resources(IndicatorsFakeQml_RESOURCES_RCC
    ${IndicatorsFakeQml_RESOURCES}
)

add_library(IndicatorsFakeQml SHARED
    ${IndicatorsFakeQml_RESOURCES_RCC}
    ${IndicatorsFakeQml_SOURCES}
)
add_definitions(-DUNITYINDICATORS_LIBRARY)

target_link_libraries(IndicatorsFakeQml)

qt5_use_modules(IndicatorsFakeQml Core Qml Quick)

file(GLOB IndicatorsFake_QMLFILES
    *.qml
    qml/FakeMenuPage.qml
)

# copy qmldir file into build directory for shadow builds
file(COPY "${CMAKE_CURRENT_SOURCE_DIR}/qmldir"
    DESTINATION ${CMAKE_CURRENT_BINARY_DIR}
)

# copy qmldir file into build directory for shadow builds
file(COPY ${IndicatorsFake_QMLFILES}
    DESTINATION ${CMAKE_CURRENT_BINARY_DIR}
)
