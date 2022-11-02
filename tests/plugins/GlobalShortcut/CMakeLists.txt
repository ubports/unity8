include_directories(
    ${CMAKE_SOURCE_DIR}/plugins/GlobalShortcut
    ${CMAKE_CURRENT_BINARY_DIR}
    )

add_definitions(-DTEST_DIR="plugins/GlobalShortcut")

add_executable(GlobalShortcutTestExec GlobalShortcutTest.cpp ${CMAKE_SOURCE_DIR}/plugins/GlobalShortcut/globalshortcut.cpp)
target_link_libraries(GlobalShortcutTestExec Qt5::Test Qt5::Quick ${Qt5Quick_LIBRARIES} GlobalShortcut-qml)
install(TARGETS GlobalShortcutTestExec
    DESTINATION "${SHELL_PRIVATE_LIBEXECDIR}/tests/plugins/GlobalShortcut"
)
install(FILES shortcut.qml
    DESTINATION "${SHELL_APP_DIR}/tests/plugins/GlobalShortcut"
)
add_lomiri_uitest(GlobalShortcut GlobalShortcutTestExec
        DEPENDS GlobalShortcut-qml
        ENVIRONMENT LD_LIBRARY_PATH=${CMAKE_BINARY_DIR}/plugins/GlobalShortcut
)
