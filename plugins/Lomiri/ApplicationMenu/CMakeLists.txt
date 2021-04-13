find_package(Qt5DBus REQUIRED)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
)

set(applicationMenu_SRCS
    applicationmenuregistry.cpp
    dbusapplicationmenuregistry.cpp
    plugin.cpp)

qt5_add_dbus_adaptor(applicationMenu_SRCS com.lomiri.MenuRegistrar.xml dbusapplicationmenuregistry.h DBusApplicationMenuRegistry)

add_library(ApplicationMenu-qml MODULE ${applicationMenu_SRCS})

target_link_libraries(ApplicationMenu-qml Qt5::DBus Qt5::Qml)

add_lomiri_plugin(Lomiri.ApplicationMenu 0.1 Lomiri/ApplicationMenu TARGETS ApplicationMenu-qml)
