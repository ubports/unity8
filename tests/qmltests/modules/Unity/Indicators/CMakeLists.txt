project(IndicatorsFakeQml)

find_package(Qt5Core REQUIRED)
find_package(Qt5Quick REQUIRED)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
    ${Qt5Core_INCLUDE_DIRS}
    ${Qt5Quick_INCLUDE_DIRS}
)

set(IndicatorsFakeQml_SOURCES
    plugin.cpp
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
# Because this is an internal support library, we want
# to expose all symbols in it. Consider changing this
# either to a static library or just using the
# files directly in targets.
set_target_properties(IndicatorsFakeQml PROPERTIES COMPILE_FLAGS -fvisibility=default)

target_link_libraries(IndicatorsFakeQml
    ${Qt5Core_LIBRARIES}
    ${Qt5Quick_LIBRARIES}
    ${GOBJECT_LDFLAGS}
    ${QMENUMODEL_LDFLAGS}
)

qt5_use_modules(IndicatorsFakeQml Qml)



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
