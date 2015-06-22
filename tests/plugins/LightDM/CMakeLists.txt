add_definitions(
    -DCURRENT_SOURCE_DIR="${CMAKE_CURRENT_SOURCE_DIR}"
    )
include_directories(
    ${CMAKE_CURRENT_BINARY_DIR}
    )

add_executable(GreeterDBusTestExec
    dbus.cpp
    ${CMAKE_SOURCE_DIR}/plugins/LightDM/Greeter.cpp
    )
qt5_use_modules(GreeterDBusTestExec Core DBus Quick Test)
target_link_libraries(GreeterDBusTestExec
    -L${CMAKE_BINARY_DIR}/tests/mocks/LightDM/liblightdm
    -llightdm-qt5-2
    )
target_include_directories(GreeterDBusTestExec PUBLIC
    ${CMAKE_SOURCE_DIR}/plugins/LightDM
    ${CMAKE_SOURCE_DIR}/tests/mocks/LightDM
    )
add_binary_qml_test(GreeterDBus "${CMAKE_BINARY_DIR}/tests/mocks/LightDM/liblightdm" MockLightDM "QML2_IMPORT_PATH=${CMAKE_BINARY_DIR}/tests/mocks")

add_executable(GreeterPamTestExec
    pam.cpp
    ${CMAKE_SOURCE_DIR}/plugins/LightDM/liblightdm/GreeterPrivate.cpp
    )
qt5_use_modules(GreeterPamTestExec Concurrent Core Test)
target_link_libraries(GreeterPamTestExec
    integratedLightDM
    )
target_include_directories(GreeterPamTestExec PUBLIC
    ${CMAKE_SOURCE_DIR}/plugins/LightDM/liblightdm
    )
add_qmltest_target(testGreeterPam "${CMAKE_CURRENT_BINARY_DIR}/GreeterPamTestExec" TRUE FALSE)
add_dependencies(testGreeterPam GreeterPamTestExec)

add_executable(GreeterUsersModelTestExec
    usersmodel.cpp
    ${CMAKE_SOURCE_DIR}/plugins/LightDM/UsersModel.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Utils/unitysortfilterproxymodelqml.cpp
    )
qt5_use_modules(GreeterUsersModelTestExec Core Test)
target_link_libraries(GreeterUsersModelTestExec
    -L${CMAKE_BINARY_DIR}/tests/mocks/LightDM/liblightdm
    -llightdm-qt5-2
    )
target_include_directories(GreeterUsersModelTestExec PUBLIC
    ${CMAKE_SOURCE_DIR}/plugins/LightDM
    ${CMAKE_SOURCE_DIR}/plugins/Utils
    ${CMAKE_SOURCE_DIR}/tests/mocks/LightDM
    )
add_binary_qml_test(GreeterUsersModel "${CMAKE_BINARY_DIR}/tests/mocks/LightDM/liblightdm" MockLightDM "LIBLIGHTDM_MOCK_MODE=full")
