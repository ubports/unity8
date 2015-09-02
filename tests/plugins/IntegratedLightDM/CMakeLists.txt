add_definitions(
    -DCURRENT_SOURCE_DIR="${CMAKE_CURRENT_SOURCE_DIR}"
    )
include_directories(
    ${CMAKE_CURRENT_BINARY_DIR}
    )

add_executable(GreeterDBusTestExec
    dbus.cpp
    ${CMAKE_SOURCE_DIR}/plugins/IntegratedLightDM/Greeter.cpp
    )
# This add_dependencies is needed since we're linking with with -L and -l below
# make seems to work but ninja breaks without it
add_dependencies(GreeterDBusTestExec MockLightDM)
qt5_use_modules(GreeterDBusTestExec Core DBus Quick Test)
target_link_libraries(GreeterDBusTestExec
    -L${CMAKE_BINARY_DIR}/tests/mocks/IntegratedLightDM/liblightdm
    -llightdm-qt5-2
    )
target_include_directories(GreeterDBusTestExec PUBLIC
    ${CMAKE_SOURCE_DIR}/plugins/IntegratedLightDM
    ${CMAKE_SOURCE_DIR}/tests/mocks/IntegratedLightDM
    )
add_unity8_uitest(GreeterDBus dbus-test-runner
    ARG_PREFIX "--parameter"
    ARGS --task $<TARGET_FILE:GreeterDBusTestExec>
    DEPENDS MockLightDM
    IMPORT_PATHS  ${UNITY_MOCKPATH}
    LIGHTDM
    )

add_executable(GreeterPamTestExec
    pam.cpp
    ${CMAKE_SOURCE_DIR}/plugins/IntegratedLightDM/liblightdm/GreeterPrivate.cpp
    )
qt5_use_modules(GreeterPamTestExec Concurrent Core Test)
target_link_libraries(GreeterPamTestExec
    integratedLightDM
    )
target_include_directories(GreeterPamTestExec PUBLIC
    ${CMAKE_SOURCE_DIR}/plugins/IntegratedLightDM/liblightdm
    )
add_qmltest_target(testGreeterPam GreeterPamTestExec COMMAND $<TARGET_FILE:GreeterPamTestExec>)

add_executable(GreeterUsersModelTestExec
    usersmodel.cpp
    ${CMAKE_SOURCE_DIR}/plugins/IntegratedLightDM/UsersModel.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Utils/unitysortfilterproxymodelqml.cpp
    )
# This add_dependencies is needed since we're linking with with -L and -l below
# make seems to work but ninja breaks without it
add_dependencies(GreeterUsersModelTestExec MockLightDM)
qt5_use_modules(GreeterUsersModelTestExec Core Test)
target_link_libraries(GreeterUsersModelTestExec
    -L${CMAKE_BINARY_DIR}/tests/mocks/IntegratedLightDM/liblightdm
    -llightdm-qt5-2
    )
target_include_directories(GreeterUsersModelTestExec PUBLIC
    ${CMAKE_SOURCE_DIR}/plugins/IntegratedLightDM
    ${CMAKE_SOURCE_DIR}/plugins/Utils
    ${CMAKE_SOURCE_DIR}/tests/mocks/IntegratedLightDM
    )
add_unity8_uitest(GreeterUsers GreeterUsersModelTestExec
    ENVIRONMENT LIBLIGHTDM_MOCK_MODE=full
    DEPENDS MockLightDM
    LIGHTDM
    )
