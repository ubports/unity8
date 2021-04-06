include_directories(
    ${GLIB_INCLUDE_DIRS}
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_SOURCE_DIR}/plugins/LightDM/IntegratedLightDM
    )

add_executable(GreeterDBusTestExec
    dbus.cpp
    ${CMAKE_SOURCE_DIR}/plugins/LightDM/Greeter.cpp
    ${CMAKE_SOURCE_DIR}/plugins/LightDM/PromptsModel.cpp
    )
# This add_dependencies is needed since we're linking with with -L and -l below
# make seems to work but ninja breaks without it
add_dependencies(GreeterDBusTestExec MockLightDM)
target_link_libraries(GreeterDBusTestExec
    Qt5::Core Qt5::DBus Qt5::Quick Qt5::Test
    MockLightDM
    intl
    )
target_include_directories(GreeterDBusTestExec PUBLIC
    ${CMAKE_SOURCE_DIR}/plugins/LightDM
    )
set_target_properties(GreeterDBusTestExec PROPERTIES INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/${SHELL_INSTALL_QML}/mocks/IntegratedLightDM/liblightdm")
install(TARGETS GreeterDBusTestExec
    DESTINATION "${SHELL_PRIVATE_LIBDIR}/tests/plugins/LightDM/IntegratedLightDM"
    )
install(FILES greeter.qml
    DESTINATION "${SHELL_APP_DIR}/tests/plugins/LightDM/IntegratedLightDM"
    )
add_unity8_uitest(GreeterDBus dbus-test-runner
    ARG_PREFIX "--parameter"
    ARGS --task $<TARGET_FILE:GreeterDBusTestExec>
    DEPENDS MockLightDM
    )

add_executable(GreeterPamTestExec
    pam.cpp
    ${CMAKE_SOURCE_DIR}/plugins/LightDM/IntegratedLightDM/liblightdm/GreeterPrivate.cpp
    )
target_link_libraries(GreeterPamTestExec
    Qt5::Concurrent Qt5::Core Qt5::Test
    integratedLightDM
    )

target_include_directories(GreeterPamTestExec PUBLIC
    ${CMAKE_SOURCE_DIR}/plugins/LightDM/IntegratedLightDM
    ${CMAKE_SOURCE_DIR}/plugins/LightDM/IntegratedLightDM/liblightdm
    )
install(TARGETS GreeterPamTestExec
    DESTINATION "${SHELL_PRIVATE_LIBDIR}/tests/plugins/LightDM/IntegratedLightDM"
    )
add_qmltest_target(testGreeterPam GreeterPamTestExec COMMAND $<TARGET_FILE:GreeterPamTestExec>)

# SessionsModelTest
add_executable(GreeterSessionsModelTestExec
    sessionsmodel.cpp
    ${CMAKE_SOURCE_DIR}/plugins/LightDM/SessionsModel.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Utils/unitysortfilterproxymodelqml.cpp
    )
add_dependencies(GreeterSessionsModelTestExec MockLightDM)
target_link_libraries(GreeterSessionsModelTestExec
    Qt5::Core Qt5::Test
    MockLightDM
    )
target_include_directories(GreeterSessionsModelTestExec PUBLIC
    ${CMAKE_SOURCE_DIR}/plugins/LightDM
    ${CMAKE_SOURCE_DIR}/plugins/Utils
    ${CMAKE_SOURCE_DIR}/tests/mocks/liblightdm/
    )
install(TARGETS GreeterSessionsModelTestExec
    DESTINATION "${SHELL_PRIVATE_LIBDIR}/tests/plugins/LightDM/IntegratedLightDM"
    )
add_unity8_uitest(GreeterSessions GreeterSessionsModelTestExec
    DEPENDS MockLightDM
    )

# UsersModelTest
add_executable(GreeterUsersModelTestExec
    usersmodel.cpp
    ${CMAKE_SOURCE_DIR}/plugins/LightDM/Greeter.cpp
    ${CMAKE_SOURCE_DIR}/plugins/LightDM/PromptsModel.cpp
    ${CMAKE_SOURCE_DIR}/plugins/LightDM/UsersModel.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Utils/unitysortfilterproxymodelqml.cpp
    )
# This add_dependencies is needed since we're linking with with -L and -l below
# make seems to work but ninja breaks without it
add_dependencies(GreeterUsersModelTestExec MockLightDM)
target_link_libraries(GreeterUsersModelTestExec
    Qt5::Core Qt5::Test
    MockLightDM
    intl
    )
target_include_directories(GreeterUsersModelTestExec PUBLIC
    ${CMAKE_SOURCE_DIR}/plugins/LightDM
    ${CMAKE_SOURCE_DIR}/plugins/Utils
    ${CMAKE_SOURCE_DIR}/tests/mocks/liblightdm
    )
set_target_properties(GreeterUsersModelTestExec PROPERTIES INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/${SHELL_INSTALL_QML}/mocks/IntegratedLightDM/liblightdm")
install(TARGETS GreeterUsersModelTestExec
    DESTINATION "${SHELL_PRIVATE_LIBDIR}/tests/plugins/LightDM/IntegratedLightDM"
    )
add_unity8_uitest(GreeterUsers GreeterUsersModelTestExec
    DEPENDS MockLightDM
    )

# PromptsModelTest
add_executable(GreeterPromptsModelTestExec
    promptsmodel.cpp
    ${CMAKE_SOURCE_DIR}/plugins/LightDM/Greeter.cpp
    ${CMAKE_SOURCE_DIR}/plugins/LightDM/PromptsModel.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Utils/unitysortfilterproxymodelqml.cpp
    )
# This add_dependencies is needed since we're linking with with -L and -l below
# make seems to work but ninja breaks without it
add_dependencies(GreeterPromptsModelTestExec MockLightDM)
target_link_libraries(GreeterPromptsModelTestExec
    Qt5::Core Qt5::Test
    MockLightDM
    intl
    )
target_include_directories(GreeterPromptsModelTestExec PUBLIC
    ${CMAKE_SOURCE_DIR}/plugins/LightDM
    ${CMAKE_SOURCE_DIR}/plugins/Utils
    ${CMAKE_SOURCE_DIR}/tests/mocks/liblightdm
    )
install(TARGETS GreeterPromptsModelTestExec
    DESTINATION "${SHELL_PRIVATE_LIBDIR}/tests/plugins/LightDM/IntegratedLightDM"
    )
add_unity8_uitest(GreeterPrompts GreeterPromptsModelTestExec
    DEPENDS MockLightDM
    )

# IntegratedTest
add_executable(GreeterIntegratedTestExec
    integrated.cpp
    )
target_link_libraries(GreeterIntegratedTestExec
    Qt5::Core Qt5::DBus Qt5::Quick Qt5::Test
    ${GLIB_LIBRARIES}
    integratedLightDMSession
    )
target_include_directories(GreeterIntegratedTestExec PUBLIC
    ${GLIB_INCLUDE_DIRS}
    ${CMAKE_SOURCE_DIR}/plugins/LightDM/IntegratedLightDM/liblightdm
    )
install(TARGETS GreeterIntegratedTestExec
    DESTINATION "${SHELL_PRIVATE_LIBDIR}/tests/plugins/LightDM/IntegratedLightDM"
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
