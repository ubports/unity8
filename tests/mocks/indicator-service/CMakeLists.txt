project(mock-indicator-service)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=c99")

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${GIO_INCLUDE_DIRS}
)

add_executable(${MOCK_INDICATOR_SERVICE_APP}
    mock-indicator-service.c
)

target_link_libraries(${MOCK_INDICATOR_SERVICE_APP} ${GIO_LDFLAGS})

set_target_properties(${MOCK_INDICATOR_SERVICE_APP} PROPERTIES COMPILE_FLAGS -fPIC)

install(TARGETS ${MOCK_INDICATOR_SERVICE_APP}
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
