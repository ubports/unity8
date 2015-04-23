add_executable(GreeterDBusTestExec
    dbus.cpp
    ${CMAKE_SOURCE_DIR}/plugins/LightDM/Greeter.cpp
    )
qt5_use_modules(GreeterDBusTestExec Core DBus Quick Test)

add_executable(GreeterUsersModelTestExec
    usersmodel.cpp
    ${CMAKE_SOURCE_DIR}/plugins/LightDM/UsersModel.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Utils/unitysortfilterproxymodelqml.cpp
    )
qt5_use_modules(GreeterUsersModelTestExec Core Test)

include_directories(
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_SOURCE_DIR}/plugins/LightDM
    ${CMAKE_SOURCE_DIR}/plugins/Utils
    ${CMAKE_SOURCE_DIR}/tests/mocks/LightDM
    )

target_link_libraries(GreeterDBusTestExec
    MockLightDM
    )

target_link_libraries(GreeterUsersModelTestExec
    MockLightDM
    )

add_definitions(-DCURRENT_SOURCE_DIR="${CMAKE_CURRENT_SOURCE_DIR}")

add_binary_qml_test(GreeterDBus "${CMAKE_BINARY_DIR}/tests/mocks/LightDM/liblightdm" MockLightDM "QML2_IMPORT_PATH=${CMAKE_BINARY_DIR}/tests/mocks")

add_binary_qml_test(GreeterUsersModel "${CMAKE_BINARY_DIR}/tests/mocks/LightDM/liblightdm" MockLightDM "LIBLIGHTDM_MOCK_MODE=full")
