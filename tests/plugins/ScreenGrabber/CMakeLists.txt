include_directories(
    ${CMAKE_SOURCE_DIR}/plugins/ScreenGrabber
    ${CMAKE_CURRENT_BINARY_DIR}
    )

add_definitions(-DTEST_DIR="plugins/ScreenGrabber")

add_executable(ScreenGrabberTestExec ScreenGrabberTest.cpp ${CMAKE_SOURCE_DIR}/plugins/ScreenGrabber/screengrabber.cpp)
qt5_use_modules(ScreenGrabberTestExec Test Quick Concurrent)
target_link_libraries(ScreenGrabberTestExec ${Qt5Quick_LIBRARIES} ScreenGrabber-qml)
install(TARGETS ScreenGrabberTestExec
    DESTINATION "${SHELL_PRIVATE_LIBDIR}/tests/plugins/ScreenGrabber"
)
install(FILES grabber.qml
    DESTINATION "${SHELL_APP_DIR}/tests/plugins/ScreenGrabber"
)
add_unity8_uitest(ScreenGrabber ScreenGrabberTestExec DEPENDS ScreenGrabber-qml)
