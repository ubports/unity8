include_directories(
    ${GLIB_INCLUDE_DIRS}
    ${CMAKE_CURRENT_BINARY_DIR}
    )

add_executable(GreeterDBusTestExec
    dbus.cpp
    ${CMAKE_SOURCE_DIR}/plugins/IntegratedLightDM/Greeter.cpp
    )
qt5_use_modules(GreeterDBusTestExec Core DBus Quick Test)
target_link_libraries(GreeterDBusTestExec MockLightDM)
target_include_directories(GreeterDBusTestExec PUBLIC
    ${CMAKE_SOURCE_DIR}/plugins/IntegratedLightDM
    ${CMAKE_SOURCE_DIR}/tests/mocks/IntegratedLightDM
    )
set_target_properties(GreeterDBusTestExec PROPERTIES INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/${SHELL_PRIVATE_LIBDIR}/qml/mocks/IntegratedLightDM/liblightdm")
install(TARGETS GreeterDBusTestExec
    DESTINATION "${SHELL_PRIVATE_LIBDIR}/tests/plugins/IntegratedLightDM"
)
install(FILES greeter.qml
    DESTINATION "${SHELL_APP_DIR}/tests/plugins/IntegratedLightDM"
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
install(TARGETS GreeterPamTestExec
    DESTINATION "${SHELL_PRIVATE_LIBDIR}/tests/plugins/IntegratedLightDM"
)
add_qmltest_target(testGreeterPam GreeterPamTestExec COMMAND $<TARGET_FILE:GreeterPamTestExec>)

add_executable(GreeterUsersModelTestExec
    usersmodel.cpp
    ${CMAKE_SOURCE_DIR}/plugins/IntegratedLightDM/UsersModel.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Utils/unitysortfilterproxymodelqml.cpp
    )
qt5_use_modules(GreeterUsersModelTestExec Core Test)
target_link_libraries(GreeterUsersModelTestExec MockLightDM)
target_include_directories(GreeterUsersModelTestExec PUBLIC
    ${CMAKE_SOURCE_DIR}/plugins/IntegratedLightDM
    ${CMAKE_SOURCE_DIR}/plugins/Utils
    ${CMAKE_SOURCE_DIR}/tests/mocks/IntegratedLightDM
    )
set_target_properties(GreeterUsersModelTestExec PROPERTIES INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/${SHELL_PRIVATE_LIBDIR}/qml/mocks/IntegratedLightDM/liblightdm")
install(TARGETS GreeterUsersModelTestExec
    DESTINATION "${SHELL_PRIVATE_LIBDIR}/tests/plugins/IntegratedLightDM"
)
add_unity8_uitest(GreeterUsers GreeterUsersModelTestExec
    ENVIRONMENT LIBLIGHTDM_MOCK_MODE=full
    DEPENDS MockLightDM
    LIGHTDM
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
    ${CMAKE_SOURCE_DIR}/plugins/IntegratedLightDM/liblightdm
    )
install(TARGETS GreeterIntegratedTestExec
    DESTINATION "${SHELL_PRIVATE_LIBDIR}/tests/plugins/IntegratedLightDM"
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
