include_directories(
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_SOURCE_DIR}/plugins/AccountsService
    ${CMAKE_SOURCE_DIR}/plugins/Unity/Launcher
    ${CMAKE_SOURCE_DIR}/plugins/Unity/Launcher/backend
    )

add_definitions(-DSM_BUSNAME=sessionBus)
add_definitions(-DSRCDIR="${CMAKE_CURRENT_SOURCE_DIR}")

set(testCommand ${CMAKE_CURRENT_BINARY_DIR}/launcherbackendtestExec
      -o ${CMAKE_BINARY_DIR}/launcherbackendtest.xml,xunitxml
      -o -,txt)
add_test(NAME launcherbackendtest COMMAND ${testCommand})
add_custom_target(launcherbackendtest ${testCommand})
add_executable(launcherbackendtestExec
    launcherbackendtest.cpp
    ${CMAKE_SOURCE_DIR}/plugins/AccountsService/AccountsService.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Unity/Launcher/backend/launcherbackend.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Unity/Launcher/common/quicklistentry.cpp
    )
qt5_use_modules(launcherbackendtestExec Test Core DBus)
