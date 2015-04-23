add_executable(SessionScreenshoterTestExec
    sessionscreenshotertest.cpp
    ${CMAKE_SOURCE_DIR}/plugins/SessionScreenshoter/sessionscreenshoter.cpp
    )
qt5_use_modules(SessionScreenshoterTestExec Core Quick Test Concurrent)

add_definitions(-DCURRENT_SOURCE_DIR="${CMAKE_CURRENT_SOURCE_DIR}")

include_directories(
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_SOURCE_DIR}/plugins/SessionScreenshoter
    )

add_binary_qml_test(SessionScreenshoter "" "" "")
