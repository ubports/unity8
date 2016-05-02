include_directories(
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_SOURCE_DIR}/plugins/Unity/Session
    ${libunity8-private_SOURCE_DIR}
    ${GLIB_INCLUDE_DIRS}
)

add_definitions(-DSM_BUSNAME=sessionBus)
add_definitions(-DSRCDIR="${CMAKE_CURRENT_SOURCE_DIR}")
add_definitions(-DSESSION_TESTING)

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
    ARG_PREFIX "--parameter"
    ARGS --task $<TARGET_FILE:sessionbackendtestExec>
)
