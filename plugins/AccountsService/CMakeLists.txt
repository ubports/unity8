add_definitions(-DSM_BUSNAME=systemBus)

add_library(AccountsService-qml MODULE
    AccountsService.cpp
    AccountsServiceDBusAdaptor.cpp
    plugin.cpp
    )

qt5_use_modules(AccountsService-qml DBus Qml)

add_unity8_plugin(AccountsService 0.1 AccountsService TARGETS AccountsService-qml)

set(POLKIT_LIB_DIR "${CMAKE_INSTALL_LOCALSTATEDIR}/lib/polkit-1")
set(POLKIT_DATA_DIR "${CMAKE_INSTALL_PREFIX}/share/polkit-1")
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

install(FILES com.canonical.unity.AccountsService.policy
        DESTINATION "${POLKIT_DATA_DIR}/actions"
    )

install(FILES 50-com.canonical.unity.AccountsService.pkla
        DESTINATION "${POLKIT_LIB_DIR}/localauthority/10-vendor.d"
    )
