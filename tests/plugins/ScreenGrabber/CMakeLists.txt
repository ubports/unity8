include_directories(
    ${CMAKE_SOURCE_DIR}/plugins/ScreenGrabber
    ${CMAKE_CURRENT_BINARY_DIR}
    )

add_definitions(
    -DCURRENT_SOURCE_DIR="${CMAKE_CURRENT_SOURCE_DIR}"
    )

add_executable(ScreenGrabberTestExec ScreenGrabberTest.cpp ${CMAKE_SOURCE_DIR}/plugins/ScreenGrabber/screengrabber.cpp)
qt5_use_modules(ScreenGrabberTestExec Test Quick)
target_link_libraries(ScreenGrabberTestExec ScreenGrabber-qml)
add_unity8_uitest(ScreenGrabber ScreenGrabberTestExec ADD_TEST)
