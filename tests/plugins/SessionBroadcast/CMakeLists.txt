macro(make_dbus_class NAME INTERFACE)
    if(${CMAKE_CURRENT_SOURCE_DIR}/interfaces.xml IS_NEWER_THAN ${CMAKE_CURRENT_BINARY_DIR}/${NAME}Adaptor.h)
        execute_process(COMMAND qdbusxml2cpp -c ${NAME}Adaptor -a ${CMAKE_CURRENT_BINARY_DIR}/${NAME}Adaptor ${CMAKE_CURRENT_SOURCE_DIR}/interfaces.xml ${INTERFACE})
    endif()
endmacro(make_dbus_class)

make_dbus_class(Broadcast com.canonical.Unity.Greeter.Broadcast)

include_directories(
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_SOURCE_DIR}/plugins/SessionBroadcast
    )

add_definitions(-DSM_BUSNAME=sessionBus)

add_executable(mock-server
    ${CMAKE_CURRENT_BINARY_DIR}/BroadcastAdaptor.cpp
    server.cpp
    BroadcastServer.cpp
    )
qt5_use_modules(mock-server Core DBus)

add_executable(sessionbroadcasttest
    ${CMAKE_SOURCE_DIR}/plugins/SessionBroadcast/SessionBroadcast.cpp
    client.cpp
    )
qt5_use_modules(sessionbroadcasttest Core DBus Test)

add_test(NAME sessionbroadcasttest
    COMMAND dbus-test-runner
        --task ${CMAKE_CURRENT_BINARY_DIR}/mock-server
        --task-name server
        --ignore-return
        --task ${CMAKE_CURRENT_BINARY_DIR}/sessionbroadcasttest
        --task-name client
        --wait-for com.canonical.Unity.Greeter.Broadcast
    )
