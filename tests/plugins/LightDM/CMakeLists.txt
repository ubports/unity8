add_executable(GreeterDBusTestExec
    dbus.cpp
    ${CMAKE_SOURCE_DIR}/plugins/LightDM/Greeter.cpp
    )
qt5_use_modules(GreeterDBusTestExec Core DBus Quick Test)

include_directories(
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_SOURCE_DIR}/plugins/LightDM
    ${CMAKE_SOURCE_DIR}/tests/mocks/LightDM
    ${LIBLIGHTDM_INCLUDE_DIRS}
    )

target_link_libraries(GreeterDBusTestExec MockLightDM-full)

add_definitions(-DCURRENT_SOURCE_DIR="${CMAKE_CURRENT_SOURCE_DIR}")

add_binary_qml_test(GreeterDBus "${CMAKE_BINARY_DIR}/tests/mocks/LightDM/full" MockLightDM-full "QML2_IMPORT_PATH=${CMAKE_BINARY_DIR}/tests/mocks")
