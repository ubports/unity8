pkg_check_modules(GSETTINGS_QT REQUIRED gsettings-qt)

include_directories(
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_SOURCE_DIR}/plugins/AccountsService
    ${CMAKE_SOURCE_DIR}/plugins/Unity/Launcher
    ${CMAKE_SOURCE_DIR}/plugins/Unity/Launcher/backend
    ${GSETTINGS_QT_INCLUDE_DIRS}
    )

add_definitions(-DSM_BUSNAME=sessionBus)
add_definitions(-DSRCDIR="${CMAKE_CURRENT_SOURCE_DIR}")
add_definitions(-DLAUNCHER_TESTING)

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
target_link_libraries(launcherbackendtestExec ${GSETTINGS_QT_LDFLAGS})
qt5_use_modules(launcherbackendtestExec Test Core DBus)

# copy .desktop files into build directory for shadow builds
file(GLOB DESKTOP_FILES *.desktop)

foreach(DESKTOP_FILE ${DESKTOP_FILES})
    file(COPY "${DESKTOP_FILE}"
        DESTINATION ${CMAKE_CURRENT_BINARY_DIR}
        )
endforeach()
