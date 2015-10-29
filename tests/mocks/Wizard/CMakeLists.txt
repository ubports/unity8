pkg_search_module(TIMEZONEMAP REQUIRED timezonemap)

include_directories(
    ${GLIB_INCLUDE_DIRS} ${TIMEZONEMAP_INCLUDE_DIRS}
    ${CMAKE_SOURCE_DIR}/plugins/Wizard
)

add_library(MockWizard-qml MODULE
    mockplugin.cpp
    MockSystem.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Wizard/PageList.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Wizard/timezonemodel.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Wizard/LocalePlugin.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Wizard/Status.cpp
)

qt5_use_modules(MockWizard-qml DBus Qml Concurrent)
target_link_libraries(MockWizard-qml ${GLIB_LDFLAGS} ${TIMEZONEMAP_LDFLAGS})
add_unity8_mock(Wizard 0.1 Wizard TARGETS MockWizard-qml)
