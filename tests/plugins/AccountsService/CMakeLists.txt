macro(make_dbus_class NAME INTERFACE)
    if(${CMAKE_CURRENT_SOURCE_DIR}/interfaces.xml IS_NEWER_THAN ${CMAKE_CURRENT_BINARY_DIR}/${NAME}Adaptor.h)
        execute_process(COMMAND qdbusxml2cpp -c ${NAME}Adaptor -a ${CMAKE_CURRENT_BINARY_DIR}/${NAME}Adaptor ${CMAKE_CURRENT_SOURCE_DIR}/interfaces.xml ${INTERFACE})
    endif()
endmacro(make_dbus_class)

make_dbus_class(Accounts org.freedesktop.Accounts)
make_dbus_class(Properties org.freedesktop.DBus.Properties)

include_directories(
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_SOURCE_DIR}/plugins/AccountsService
    )

add_definitions(-DSM_BUSNAME=sessionBus)

add_executable(mock-server
    ${CMAKE_CURRENT_BINARY_DIR}/AccountsAdaptor.cpp
    ${CMAKE_CURRENT_BINARY_DIR}/PropertiesAdaptor.cpp
    server.cpp
    AccountsServer.cpp
    PropertiesServer.cpp
    )
qt5_use_modules(mock-server Core DBus)

add_executable(test-accountsservice
    ${CMAKE_SOURCE_DIR}/plugins/AccountsService/AccountsService.cpp
    ${CMAKE_SOURCE_DIR}/plugins/AccountsService/AccountsBindings.cpp
    client.cpp
    )
qt5_use_modules(test-accountsservice Core DBus Test)

add_test(NAME test-accountsservice
    COMMAND dbus-test-runner
        --task ${CMAKE_CURRENT_BINARY_DIR}/mock-server
        --task-name server
        --ignore-return
        --task ${CMAKE_CURRENT_BINARY_DIR}/test-accountsservice
        --task-name client
        --wait-for org.freedesktop.Accounts
    )
