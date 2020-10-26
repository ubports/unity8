pkg_search_module(GD3 REQUIRED gnome-desktop-3.0)

include_directories(
    ${GD3_INCLUDE_DIRS} ${GLIB_INCLUDE_DIRS} ${GEONAMES_INCLUDE_DIRS}
    ${CMAKE_SOURCE_DIR}/plugins/Wizard
)

add_library(MockWizard-qml MODULE
    mockplugin.cpp
    MockSystem.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Wizard/Changelog.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Wizard/PageList.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Wizard/timezonemodel.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Wizard/LocalePlugin.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Wizard/Status.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Wizard/keyboardLayoutsModel.cpp
)

target_link_libraries(MockWizard-qml Qt5::DBus Qt5::Qml ${GD3_LDFLAGS} ${GLIB_LDFLAGS} ${GEONAMES_LDFLAGS})
add_unity8_mock(Wizard 0.1 Wizard TARGETS MockWizard-qml)
