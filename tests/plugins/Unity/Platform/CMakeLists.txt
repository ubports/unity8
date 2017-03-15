
include_directories(
    ${Qt5Core_INCLUDE_DIRS}
    ${Qt5DBus_INCLUDE_DIRS}
    ${Qt5Test_INCLUDE_DIRS}
    ${QTDBUSTEST_INCLUDE_DIRS}
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_SOURCE_DIR}/plugins/Unity/Platform
)

add_executable(platformtest
    platformtest.cpp
    ${CMAKE_SOURCE_DIR}/plugins/Unity/Platform/platform.cpp
    )
    
target_link_libraries(platformtest
    Qt5::Core
    Qt5::DBus
    Qt5::Test
    ${QTDBUSTEST_LDFLAGS}
    )

add_unity8_unittest(platformtest qdbus-simple-test-runner
    ARGS "${CMAKE_BINARY_DIR}/platformtest"
    )