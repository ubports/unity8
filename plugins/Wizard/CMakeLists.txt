pkg_search_module(GD3 REQUIRED gnome-desktop-3.0)

include_directories(SYSTEM ${GD3_INCLUDE_DIRS} ${GLIB_INCLUDE_DIRS} ${GEONAMES_INCLUDE_DIRS})

add_library(Wizard-qml MODULE
    plugin.cpp
    PageList.cpp
    System.cpp
    LocalePlugin.cpp
    timezonemodel.cpp
    Status.cpp
    keyboardLayoutsModel.cpp
)

qt5_use_modules(Wizard-qml DBus Qml)
target_link_libraries(Wizard-qml ${GD3_LDFLAGS} ${GLIB_LDFLAGS} ${GEONAMES_LDFLAGS})
add_unity8_plugin(Wizard 0.1 Wizard TARGETS Wizard-qml)

set(POLKIT_LIB_DIR "${CMAKE_INSTALL_LOCALSTATEDIR}/lib/polkit-1")
install(FILES 50-com.canonical.unity.wizard.pkla DESTINATION ${POLKIT_LIB_DIR}/localauthority/10-vendor.d)
