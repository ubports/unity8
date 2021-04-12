add_definitions(-DSM_BUSNAME=systemBus)
include_directories(${GLIB_INCLUDE_DIRS})

add_library(AccountsService-qml MODULE
    AccountsService.cpp
    AccountsServiceDBusAdaptor.cpp
    plugin.cpp
    )

target_link_libraries(AccountsService-qml
    Qt5::DBus Qt5::Qml
    ${GLIB_LIBRARIES}
    )

add_lomiri_plugin(AccountsService 0.1 AccountsService TARGETS AccountsService-qml)

set(DBUS_IFACE_DIR "${CMAKE_INSTALL_PREFIX}/share/dbus-1/interfaces")
set(ACCOUNTS_IFACE_DIR "${CMAKE_INSTALL_PREFIX}/share/accountsservice/interfaces")

install(FILES com.canonical.lomiri.AccountsService.xml
        DESTINATION "${DBUS_IFACE_DIR}"
    )

# Create accountsservice symlink for above dbus interface
install(CODE "
execute_process(COMMAND mkdir -p \"\$ENV{DESTDIR}${ACCOUNTS_IFACE_DIR}\")
execute_process(COMMAND ln -sf ../../dbus-1/interfaces/com.canonical.lomiri.AccountsService.xml \"\$ENV{DESTDIR}${ACCOUNTS_IFACE_DIR}\")
    ")
