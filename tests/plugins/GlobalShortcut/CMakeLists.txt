include_directories(
    ${CMAKE_SOURCE_DIR}/plugins/GlobalShortcut
    ${CMAKE_CURRENT_BINARY_DIR}
    )

add_definitions(
    -DCURRENT_SOURCE_DIR="${CMAKE_CURRENT_SOURCE_DIR}"
    )
add_definitions(-DBUILT_PLUGINS_DIR="${CMAKE_BINARY_DIR}/plugins")

add_executable(GlobalShortcutTestExec GlobalShortcutTest.cpp ${CMAKE_SOURCE_DIR}/plugins/GlobalShortcut/globalshortcut.cpp)
qt5_use_modules(GlobalShortcutTestExec Test Quick)
target_link_libraries(GlobalShortcutTestExec ${Qt5Quick_LIBRARIES} GlobalShortcut-qml)
add_unity8_uitest(GlobalShortcut GlobalShortcutTestExec DEPENDS GlobalShortcut-qml)
