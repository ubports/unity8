add_definitions(
    -DCURRENT_SOURCE_DIR="${CMAKE_CURRENT_SOURCE_DIR}"
    )
include_directories(
    ${GLIB_INCLUDE_DIRS}
    ${CMAKE_CURRENT_BINARY_DIR}
    )

add_executable(GreeterDBusTestExec
    dbus.cpp
    ${CMAKE_SOURCE_DIR}/plugins/LightDM/Greeter.cpp
    )
# This add_dependencies is needed since we're linking with with -L and -l below
# make seems to work but ninja breaks without it
add_dependencies(GreeterDBusTestExec MockLightDM)
qt5_use_modules(GreeterDBusTestExec Core DBus Quick Test)
target_link_libraries(GreeterDBusTestExec
    MockLightDM
    )
target_include_directories(GreeterDBusTestExec PUBLIC
    ${CMAKE_SOURCE_DIR}/plugins/LightDM
    ${CMAKE_SOURCE_DIR}/tests/mocks/LightDM/IntegratedLightDM
    )
add_unity8_uitest(GreeterDBus dbus-test-runner
    ARG_PREFIX "--parameter"
    ARGS --task $<TARGET_FILE:GreeterDBusTestExec>
    DEPENDS MockLightDM
    IMPORT_PATHS  ${UNITY_MOCKPATH}
    )

add_executable(GreeterPamTestExec
    pam.cpp
    ${CMAKE_SOURCE_DIR}/plugins/LightDM/IntegratedLightDM/liblightdm/GreeterPrivate.cpp
    )
qt5_use_modules(GreeterPamTestExec Concurrent Core Test)
target_link_libraries(GreeterPamTestExec
    integratedLightDM
    )

target_include_directories(GreeterPamTestExec PUBLIC
    ${CMAKE_SOURCE_DIR}/plugins/LightDM/IntegratedLightDM
    ${CMAKE_SOURCE_DIR}/plugins/LightDM/IntegratedLightDM/liblightdm
    )
add_qmltest_target(testGreeterPam GreeterPamTestExec COMMAND $<TARGET_FILE:GreeterPamTestExec>)

# SessionsModelTest
add_executable(GreeterSessionsModelTestExec
    sessionsmodel.cpp
    ${CMAKE_SOURCE_DIR}/plugins/LightDM/SessionsModel.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Utils/unitysortfilterproxymodelqml.cpp
    )
add_dependencies(GreeterSessionsModelTestExec MockLightDM)
qt5_use_modules(GreeterSessionsModelTestExec Core Test)
target_link_libraries(GreeterSessionsModelTestExec
    MockLightDM
    )
target_include_directories(GreeterSessionsModelTestExec PUBLIC
    ${CMAKE_SOURCE_DIR}/plugins/LightDM
    ${CMAKE_SOURCE_DIR}/plugins/Utils
    ${CMAKE_SOURCE_DIR}/tests/mocks/LightDM/IntegratedLightDM
    )
add_unity8_uitest(GreeterSessions GreeterSessionsModelTestExec
    ENVIRONMENT LIBLIGHTDM_MOCK_MODE=full
    DEPENDS MockLightDM
    )

# UsersModelTest
add_executable(GreeterUsersModelTestExec
    usersmodel.cpp
    ${CMAKE_SOURCE_DIR}/plugins/LightDM/UsersModel.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Utils/unitysortfilterproxymodelqml.cpp
    )
# This add_dependencies is needed since we're linking with with -L and -l below
# make seems to work but ninja breaks without it
add_dependencies(GreeterUsersModelTestExec MockLightDM)
qt5_use_modules(GreeterUsersModelTestExec Core Test)
target_link_libraries(GreeterUsersModelTestExec
    MockLightDM
    )
target_include_directories(GreeterUsersModelTestExec PUBLIC
    ${CMAKE_SOURCE_DIR}/plugins/LightDM
    ${CMAKE_SOURCE_DIR}/plugins/Utils
    ${CMAKE_SOURCE_DIR}/tests/mocks/LightDM/IntegratedLightDM
    )
add_unity8_uitest(GreeterUsers GreeterUsersModelTestExec
    ENVIRONMENT LIBLIGHTDM_MOCK_MODE=full
    DEPENDS MockLightDM
    )

add_executable(GreeterIntegratedTestExec
    integrated.cpp
    )
qt5_use_modules(GreeterIntegratedTestExec Core DBus Quick Test)
target_link_libraries(GreeterIntegratedTestExec
    ${GLIB_LIBRARIES}
    integratedLightDMSession
    )
target_include_directories(GreeterIntegratedTestExec PUBLIC
    ${GLIB_INCLUDE_DIRS}
    ${CMAKE_SOURCE_DIR}/plugins/LightDM/IntegratedLightDM/liblightdm
    )
add_unity8_unittest(GreeterIntegrated dbus-test-runner
    ENVIRONMENT LD_LIBRARY_PATH=${CMAKE_BINARY_DIR}/plugins/IntegratedLightDM/liblightdm/
    ARG_PREFIX "--parameter"
    ARGS
        --task $<TARGET_FILE:mock-server>
        --task-name server
        --ignore-return
        --task $<TARGET_FILE:GreeterIntegratedTestExec>
        --task-name client
        --wait-for org.freedesktop.Accounts
    DEPENDS integratedLightDMSession
    )
