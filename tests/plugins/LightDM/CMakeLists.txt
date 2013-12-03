add_executable(testLightDMDBus
    dbus.cpp
    ${CMAKE_SOURCE_DIR}/plugins/LightDM/Greeter.cpp
    )
qt5_use_modules(testLightDMDBus Core DBus Quick Test)

include_directories(
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_SOURCE_DIR}/plugins/LightDM
    ${LIBLIGHTDM_INCLUDE_DIRS}
    )

target_link_libraries(testLightDMDBus
    -L${CMAKE_BINARY_DIR}/tests/mocks/LightDM/full
    -llightdm-qt5-2
    )

add_definitions(-DCURRENT_SOURCE_DIR="${CMAKE_CURRENT_SOURCE_DIR}")

add_test(NAME testLightDMDBus
    COMMAND dbus-launch env QML2_IMPORT_PATH=${CMAKE_BINARY_DIR}/tests/mocks LD_LIBRARY_PATH=${CMAKE_BINARY_DIR}/tests/mocks/LightDM/full ${CMAKE_CURRENT_BINARY_DIR}/testLightDMDBus
    )
