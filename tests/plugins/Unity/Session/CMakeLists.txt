macro(make_dbus_class NAME INTERFACE)
    if(${CMAKE_CURRENT_SOURCE_DIR}/interfaces.xml IS_NEWER_THAN ${CMAKE_CURRENT_BINARY_DIR}/${NAME}Adaptor.h)
        execute_process(COMMAND ${QDBUSXML2CPP_EXECUTABLE} -c ${NAME}Adaptor -a ${CMAKE_CURRENT_BINARY_DIR}/${NAME}Adaptor ${CMAKE_CURRENT_SOURCE_DIR}/interfaces.xml ${INTERFACE})
    endif()
endmacro(make_dbus_class)

make_dbus_class(LightDMSession org.freedesktop.DisplayManager.Session)
make_dbus_class(LogindManager org.freedesktop.login1.Manager)
make_dbus_class(LogindSession org.freedesktop.login1.Session)

include_directories(
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_SOURCE_DIR}/plugins/Unity/Session
    ${libunity8-private_SOURCE_DIR}
    ${GLIB_INCLUDE_DIRS}
)

add_definitions(-DSM_BUSNAME=sessionBus)
add_definitions(-DSRCDIR="${CMAKE_CURRENT_SOURCE_DIR}")
add_definitions(-DSESSION_TESTING)

### LightDMServer
add_executable(LightDMServer
    ${CMAKE_CURRENT_BINARY_DIR}/LightDMSessionAdaptor.cpp
    ${CMAKE_CURRENT_BINARY_DIR}/LogindManagerAdaptor.cpp
    ${CMAKE_CURRENT_BINARY_DIR}/LogindSessionAdaptor.cpp
    LightDMServer.cpp
    LogindServer.cpp
    server.cpp
)
qt5_use_modules(LightDMServer Core DBus)

### SessionBackendTest
add_executable(sessionbackendtestExec
    sessionbackendtest.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Unity/Session/dbusunitysessionservice.cpp
)
target_link_libraries(sessionbackendtestExec
    unity8-private
    ${GLIB_LIBRARIES}
    )
qt5_use_modules(sessionbackendtestExec Test Core Qml DBus)

add_unity8_unittest(SessionBackend dbus-test-runner
    ENVIRONMENT XDG_SESSION_PATH=/session
    ARG_PREFIX "--parameter"
    ARGS
        --task $<TARGET_FILE:LightDMServer>
        --task-name server
        --ignore-return
        --task $<TARGET_FILE:sessionbackendtestExec>
        --task-name client
        --wait-for org.freedesktop.DisplayManager
)
