project(indicator-test-service)
pkg_search_module(GIO REQUIRED gio-2.0)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=c99")

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${GIO_INCLUDE_DIRS}
)

set(INDICATOR_TEST_SERVICE_SRC
    indicator-test-service.c
)

add_executable(${INDICATOR_TEST_SERVICE_APP}
    ${INDICATOR_TEST_SERVICE_SRC}
)

target_link_libraries(${INDICATOR_TEST_SERVICE_APP} ${GIO_LDFLAGS})

set_target_properties(${INDICATOR_TEST_SERVICE_APP} PROPERTIES COMPILE_FLAGS -fPIC)

install(TARGETS ${INDICATOR_TEST_SERVICE_APP}
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
