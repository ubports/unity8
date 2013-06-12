project(IndicatorsClientFakeQml)

find_package(Qt5Core REQUIRED)
find_package(Qt5Quick REQUIRED)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
    ${Qt5Core_INCLUDE_DIRS}
    ${Qt5Quick_INCLUDE_DIRS}
)

set(IndicatorsClientFakeQml_SOURCES
    plugin.cpp
)

set(IndicatorsClientFakeQml_RESOURCES
    indicatorsclient_fake.qrc
)

qt5_add_resources(IndicatorsClientFakeQml_RESOURCES_RCC
    ${IndicatorsClientFakeQml_RESOURCES}
)

add_library(IndicatorsClientFakeQml SHARED
    ${IndicatorsClientFakeQml_RESOURCES_RCC}
    ${IndicatorsClientFakeQml_SOURCES}
)
# Because this is an internal support library, we want
# to expose all symbols in it. Consider changing this
# either to a static library or just using the
# files directly in targets.
set_target_properties(IndicatorsClientFakeQml PROPERTIES COMPILE_FLAGS -fvisibility=default)

target_link_libraries(IndicatorsClientFakeQml
    ${Qt5Core_LIBRARIES}
    ${Qt5Quick_LIBRARIES}
    ${GOBJECT_LDFLAGS}
    ${QMENUMODEL_LDFLAGS}
)

qt5_use_modules(IndicatorsClientFakeQml Qml)



file(GLOB IndicatorsClientFake_QMLFILES
    *.qml
    qml/FakeMenuPage.qml
)

# copy qmldir file into build directory for shadow builds
file(COPY "${CMAKE_CURRENT_SOURCE_DIR}/qmldir"
    DESTINATION ${CMAKE_CURRENT_BINARY_DIR}
)

# copy qmldir file into build directory for shadow builds
file(COPY ${IndicatorsClientFake_QMLFILES}
    DESTINATION ${CMAKE_CURRENT_BINARY_DIR}
)
