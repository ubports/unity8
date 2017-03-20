
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


install(TARGETS platformtest
    DESTINATION "${SHELL_PRIVATE_LIBDIR}/tests/plugins/Unity/Platform"
)

add_unity8_unittest(Platform qdbus-simple-test-runner
    ARGS $<TARGET_FILE:platformtest>
    )
