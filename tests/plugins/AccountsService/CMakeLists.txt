macro(make_dbus_class NAME INTERFACE)
    if(${CMAKE_CURRENT_SOURCE_DIR}/interfaces.xml IS_NEWER_THAN ${CMAKE_CURRENT_BINARY_DIR}/${NAME}Adaptor.h)
        execute_process(COMMAND ${QDBUSXML2CPP_EXECUTABLE} -c ${NAME}Adaptor -i types.h -a ${CMAKE_CURRENT_BINARY_DIR}/${NAME}Adaptor ${CMAKE_CURRENT_SOURCE_DIR}/interfaces.xml ${INTERFACE})
    endif()
endmacro(make_dbus_class)

make_dbus_class(Accounts org.freedesktop.Accounts)
make_dbus_class(Input com.ubuntu.AccountsService.Input)
make_dbus_class(Properties org.freedesktop.DBus.Properties)
make_dbus_class(SecurityPrivacy com.ubuntu.touch.AccountsService.SecurityPrivacy)
make_dbus_class(Location com.ubuntu.location.providers.here.AccountsService)
make_dbus_class(AccountsUser org.freedesktop.Accounts.User)
make_dbus_class(AccountsPrivate com.canonical.unity.AccountsService.Private)
make_dbus_class(UscInput com.canonical.Unity.Input)

include_directories(
    ${GLIB_INCLUDE_DIRS}
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_SOURCE_DIR}/plugins/AccountsService
    )

link_libraries(
    ${GLIB_LIBRARIES}
    )

add_definitions(-DSM_BUSNAME=sessionBus)

add_executable(mock-server
    ${CMAKE_CURRENT_BINARY_DIR}/AccountsAdaptor.cpp
    ${CMAKE_CURRENT_BINARY_DIR}/AccountsPrivateAdaptor.cpp
    ${CMAKE_CURRENT_BINARY_DIR}/AccountsUserAdaptor.cpp
    ${CMAKE_CURRENT_BINARY_DIR}/InputAdaptor.cpp
    ${CMAKE_CURRENT_BINARY_DIR}/PropertiesAdaptor.cpp
    ${CMAKE_CURRENT_BINARY_DIR}/LocationAdaptor.cpp
    ${CMAKE_CURRENT_BINARY_DIR}/SecurityPrivacyAdaptor.cpp
    ${CMAKE_CURRENT_BINARY_DIR}/UscInputAdaptor.cpp
    server.cpp
    AccountsServer.cpp
    PropertiesServer.cpp
    UscServer.cpp
    )
qt5_use_modules(mock-server Core DBus)

add_executable(test-accountsservice
    ${CMAKE_SOURCE_DIR}/plugins/AccountsService/AccountsService.cpp
    ${CMAKE_SOURCE_DIR}/plugins/AccountsService/AccountsServiceDBusAdaptor.cpp
    client.cpp
    )
qt5_use_modules(test-accountsservice Core DBus Test)

add_unity8_unittest(AccountsService dbus-test-runner
    ARG_PREFIX "--parameter"
    ARGS
        --task $<TARGET_FILE:mock-server>
        --task-name server
        --ignore-return
        --task $<TARGET_FILE:test-accountsservice>
        --task-name client
        --wait-for org.freedesktop.Accounts
    )
