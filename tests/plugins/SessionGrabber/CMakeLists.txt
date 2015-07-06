add_executable(SessionGrabberTestExec
    sessiongrabbertest.cpp
    ${CMAKE_SOURCE_DIR}/plugins/SessionGrabber/sessiongrabber.cpp
    )
qt5_use_modules(SessionGrabberTestExec Core Quick Test Concurrent)

add_definitions(-DCURRENT_SOURCE_DIR="${CMAKE_CURRENT_SOURCE_DIR}")

include_directories(
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_SOURCE_DIR}/plugins/SessionGrabber
    )

add_unity8_uitest(SessionGrabber SessionGrabberTestExec)
