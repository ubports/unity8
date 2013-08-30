macro(make_dbus_class PREFIX SERVICE INTERFACE)
    if (${CMAKE_CURRENT_SOURCE_DIR}/interfaces.xml IS_NEWER_THAN ${CMAKE_CURRENT_BINARY_DIR}/${PREFIX}${INTERFACE}Adaptor.h)
        execute_process(COMMAND qdbusxml2cpp -c ${PREFIX}${INTERFACE}Adaptor -a ${CMAKE_CURRENT_BINARY_DIR}/${PREFIX}${INTERFACE}Adaptor ${CMAKE_CURRENT_SOURCE_DIR}/interfaces.xml ${SERVICE}.${INTERFACE})
    endif ()
endmacro(make_dbus_class)

make_dbus_class(LightDM org.freedesktop.DisplayManager Session)
make_dbus_class(Login org.freedesktop.login1 Manager)
make_dbus_class(Login org.freedesktop.login1 Session)
make_dbus_class(Login org.freedesktop.DBus Properties)

include_directories(
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_SOURCE_DIR}/plugins/SessionManager
    )

add_definitions(-DSM_BUSNAME=sessionBus)

add_executable(sessionmanagermock
    ${CMAKE_CURRENT_BINARY_DIR}/LightDMSessionAdaptor.cpp
    ${CMAKE_CURRENT_BINARY_DIR}/LoginManagerAdaptor.cpp
    ${CMAKE_CURRENT_BINARY_DIR}/LoginPropertiesAdaptor.cpp
    ${CMAKE_CURRENT_BINARY_DIR}/LoginSessionAdaptor.cpp
    server.cpp
    LightDMSessionServer.cpp
    LoginManagerServer.cpp
    LoginSessionServer.cpp
    )
qt5_use_modules(sessionmanagermock Core DBus)

add_executable(sessionmanagertest
    ${CMAKE_SOURCE_DIR}/plugins/SessionManager/SessionManager.cpp
    client.cpp
    )
qt5_use_modules(sessionmanagertest Core DBus Test)

add_test(NAME sessionmanagertest
    COMMAND env
        XDG_SESSION_ID=sessionid
        XDG_SESSION_PATH=/mocksession/lightdm
        dbus-test-runner
        --task ${CMAKE_CURRENT_BINARY_DIR}/sessionmanagermock
        --task-name server
        --ignore-return
        --task ${CMAKE_CURRENT_BINARY_DIR}/sessionmanagertest
        --task-name client
        --wait-for org.freedesktop.login1
    )
