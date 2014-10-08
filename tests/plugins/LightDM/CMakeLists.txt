add_executable(test-lightdm-dbus
    dbus.cpp
    ${CMAKE_SOURCE_DIR}/plugins/LightDM/DBusGreeter.cpp
    ${CMAKE_SOURCE_DIR}/plugins/LightDM/DBusGreeterList.cpp
    ${CMAKE_SOURCE_DIR}/plugins/LightDM/Greeter.cpp
    )
qt5_use_modules(test-lightdm-dbus Core DBus Quick Test)

include_directories(
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_SOURCE_DIR}/plugins/LightDM
    ${CMAKE_SOURCE_DIR}/tests/mocks/LightDM
    ${LIBLIGHTDM_INCLUDE_DIRS}
    )

add_dependencies(test-lightdm-dbus MockLightDM-full)
target_link_libraries(test-lightdm-dbus
    -L${CMAKE_BINARY_DIR}/tests/mocks/LightDM/full
    -llightdm-qt5-2
    )

add_definitions(-DCURRENT_SOURCE_DIR="${CMAKE_CURRENT_SOURCE_DIR}")

add_custom_target(testLightDMDBus xvfb-run --server-args "-screen 0 1024x768x24" --auto-servernum dbus-launch env QML2_IMPORT_PATH=${CMAKE_BINARY_DIR}/tests/mocks LD_LIBRARY_PATH=${CMAKE_BINARY_DIR}/tests/mocks/LightDM/full ${CMAKE_CURRENT_BINARY_DIR}/test-lightdm-dbus)
add_dependencies(testLightDMDBus test-lightdm-dbus)

add_dependencies(qmluitests testLightDMDBus)
