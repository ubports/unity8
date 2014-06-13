include_directories(
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_SOURCE_DIR}/plugins/Unity/Session
)

add_definitions(-DSM_BUSNAME=sessionBus)
add_definitions(-DSRCDIR="${CMAKE_CURRENT_SOURCE_DIR}")
add_definitions(-DSESSION_TESTING)

### SessionBackendTest
set(testBackendCommand dbus-test-runner --task ${CMAKE_CURRENT_BINARY_DIR}/sessionbackendtestExec
      --parameter -o --parameter ${CMAKE_BINARY_DIR}/sessionbackendtest.xml,xunitxml
      --parameter -o --parameter -,txt)
add_test(NAME sessionbackendtest COMMAND ${testBackendCommand})
add_custom_target(sessionbackendtest ${testBackendCommand})
add_executable(sessionbackendtestExec
    sessionbackendtest.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Unity/Session/dbusunitysessionservice.cpp
)
qt5_use_modules(sessionbackendtestExec Test Core Qml DBus)
