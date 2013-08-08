include(Plugins)

add_definitions(-DSM_BUSNAME=systemBus)

add_library(AccountsService-qml MODULE
    AccountsService.cpp
    plugin.cpp
    )

qt5_use_modules(AccountsService-qml DBus Qml)

export_qmlfiles(AccountsService AccountsService)
export_qmlplugin(AccountsService 0.1 AccountsService TARGETS AccountsService-qml)

set(POLICYKIT_DIR "${CMAKE_INSTALL_PREFIX}/share/polkit-1")
set(DBUS_IFACE_DIR "${CMAKE_INSTALL_PREFIX}/share/dbus-1/interfaces")
set(ACCOUNTS_IFACE_DIR "${CMAKE_INSTALL_PREFIX}/share/accountsservice/interfaces")

install(FILES com.canonical.unity.AccountsService.xml
        DESTINATION "${DBUS_IFACE_DIR}"
    )

# Create accountsservice symlink for above dbus interface
install(CODE "
execute_process(COMMAND mkdir -p \"$ENV{DESTDIR}${ACCOUNTS_IFACE_DIR}\")
execute_process(COMMAND ln -sf ../../dbus-1/interfaces/com.canonical.unity.AccountsService.xml \"$ENV{DESTDIR}${ACCOUNTS_IFACE_DIR}\")
    ")

install(FILES com.canonical.unity.AccountsService.policy
        DESTINATION "${POLICYKIT_DIR}/actions"
    )

install(FILES com.canonical.unity.AccountsService.rules
        DESTINATION "${POLICYKIT_DIR}/rules.d"
    )
