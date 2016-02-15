pkg_search_module(TIMEZONEMAP REQUIRED timezonemap)

include_directories(${GLIB_INCLUDE_DIRS} ${TIMEZONEMAP_INCLUDE_DIRS})

qt5_add_resources(olsen-resources ui.qrc)

add_library(Wizard-qml MODULE
    plugin.cpp
    PageList.cpp
    System.cpp
    LocalePlugin.cpp
    timezonemodel.cpp
    Status.cpp
    ${olsen-resources}
)

qt5_use_modules(Wizard-qml DBus Qml Gui Concurrent)
target_link_libraries(Wizard-qml ${GLIB_LDFLAGS} ${TIMEZONEMAP_LDFLAGS})
add_unity8_plugin(Wizard 0.1 Wizard TARGETS Wizard-qml)

set(POLKIT_LIB_DIR "${CMAKE_INSTALL_LOCALSTATEDIR}/lib/polkit-1")
install(FILES 50-com.canonical.unity.wizard.pkla DESTINATION ${POLKIT_LIB_DIR}/localauthority/10-vendor.d)
