find_package(Qt5DBus REQUIRED)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
)

set(applicationMenu_SRCS
    applicationmenuregistry.cpp
    dbusapplicationmenuregistry.cpp
    plugin.cpp)

qt5_add_dbus_adaptor(applicationMenu_SRCS com.ubuntu.MenuRegistrar.xml dbusapplicationmenuregistry.h DBusApplicationMenuRegistry)

add_library(ApplicationMenu-qml MODULE ${applicationMenu_SRCS})

qt5_use_modules(ApplicationMenu-qml DBus Qml)

add_unity8_plugin(Unity.ApplicationMenu 0.1 Unity/ApplicationMenu TARGETS ApplicationMenu-qml)
