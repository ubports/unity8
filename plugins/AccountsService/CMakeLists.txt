add_definitions(-DSM_BUSNAME=systemBus)
include_directories(${GLIB_INCLUDE_DIRS})

add_library(AccountsService-qml MODULE
    AccountsService.cpp
    AccountsServiceDBusAdaptor.cpp
    plugin.cpp
    )

qt5_use_modules(AccountsService-qml DBus Qml)

target_link_libraries(AccountsService-qml
    ${GLIB_LIBRARIES}
    )

add_unity8_plugin(AccountsService 0.1 AccountsService TARGETS AccountsService-qml)

set(DBUS_IFACE_DIR "${CMAKE_INSTALL_PREFIX}/share/dbus-1/interfaces")
set(ACCOUNTS_IFACE_DIR "${CMAKE_INSTALL_PREFIX}/share/accountsservice/interfaces")

install(FILES com.canonical.unity.AccountsService.xml
        DESTINATION "${DBUS_IFACE_DIR}"
    )

# Create accountsservice symlink for above dbus interface
install(CODE "
execute_process(COMMAND mkdir -p \"\$ENV{DESTDIR}${ACCOUNTS_IFACE_DIR}\")
execute_process(COMMAND ln -sf ../../dbus-1/interfaces/com.canonical.unity.AccountsService.xml \"\$ENV{DESTDIR}${ACCOUNTS_IFACE_DIR}\")
    ")
