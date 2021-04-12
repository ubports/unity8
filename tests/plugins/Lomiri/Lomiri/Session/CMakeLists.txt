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
    ${CMAKE_SOURCE_DIR}/plugins/Lomiri/Session
    ${liblomiri-private_SOURCE_DIR}
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
target_link_libraries(LightDMServer Qt5::Core Qt5::DBus)
install(TARGETS LightDMServer
    DESTINATION "${SHELL_PRIVATE_LIBDIR}/tests/plugins/Lomiri/Session"
    )

### Preload
add_library(SessionBackendTestPreload SHARED
    preload.c
)
target_link_libraries(SessionBackendTestPreload
    ${GLIB_LIBRARIES}
    )
install(TARGETS SessionBackendTestPreload
    DESTINATION "${SHELL_PRIVATE_LIBDIR}/tests/plugins/Lomiri/Session"
    )

### SessionBackendTest
add_executable(sessionbackendtestExec
    sessionbackendtest.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Lomiri/Session/dbuslomirisessionservice.cpp
)
target_link_libraries(sessionbackendtestExec
    lomiri-private
    ${GLIB_LIBRARIES}
    )
target_link_libraries(sessionbackendtestExec Qt5::Test Qt5::Core Qt5::Qml Qt5::DBus)
install(TARGETS sessionbackendtestExec
    DESTINATION "${SHELL_PRIVATE_LIBDIR}/tests/plugins/Lomiri/Session"
)

add_lomiri_unittest(SessionBackend dbus-test-runner
    ENVIRONMENT LD_PRELOAD=$<TARGET_FILE:SessionBackendTestPreload>
                XDG_SESSION_PATH=/session
    ARG_PREFIX "--parameter"
    ARGS
        --task $<TARGET_FILE:LightDMServer>
        --task-name server
        --ignore-return
        --task $<TARGET_FILE:sessionbackendtestExec>
        --task-name client
        --wait-for org.freedesktop.DisplayManager
)
