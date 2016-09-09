macro(make_dbus_class NAME INTERFACE)
    if(${CMAKE_CURRENT_SOURCE_DIR}/interfaces.xml IS_NEWER_THAN ${CMAKE_CURRENT_BINARY_DIR}/${NAME}Adaptor.h)
        execute_process(COMMAND ${QDBUSXML2CPP_EXECUTABLE} -c ${NAME}Adaptor -a ${CMAKE_CURRENT_BINARY_DIR}/${NAME}Adaptor ${CMAKE_CURRENT_SOURCE_DIR}/interfaces.xml ${INTERFACE})
    endif()
endmacro(make_dbus_class)

make_dbus_class(Broadcast com.canonical.Unity.Greeter.Broadcast)

add_definitions(-DSM_BUSNAME=sessionBus)

include_directories(
    ${GLIB_INCLUDE_DIRS}
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_SOURCE_DIR}/plugins/SessionBroadcast
)

link_libraries(
    ${GLIB_LIBRARIES}
)

add_executable(MockBroadcastServer
    ${CMAKE_CURRENT_BINARY_DIR}/BroadcastAdaptor.cpp
    server.cpp
    BroadcastServer.cpp
)
qt5_use_modules(MockBroadcastServer Core DBus)

### SessionBroadcastTest
add_executable(sessionbroadcasttestExec
    ${CMAKE_SOURCE_DIR}/plugins/SessionBroadcast/SessionBroadcast.cpp
    sessionbroadcasttest.cpp
)
qt5_use_modules(sessionbroadcasttestExec Test Core Qml DBus)

add_unity8_unittest(SessionBroadcast dbus-test-runner
    ARG_PREFIX "--parameter"
    ARGS
        --task $<TARGET_FILE:MockBroadcastServer>
        --task-name server
        --ignore-return
        --task $<TARGET_FILE:sessionbroadcasttestExec>
        --task-name client
        --wait-for com.canonical.Unity.Greeter.Broadcast
)
