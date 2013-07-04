project(indicators_client)
set(INDICATORS_CLIENT_APP indicators-client)

set(INDICATORS_CLIENT_SRC
    main.cpp
    indicatorsclient.cpp
)

set(INDICATORS_CLIENT_HEADERS
    indicatorsclient.h
)
add_executable(${INDICATORS_CLIENT_APP}
    ${INDICATORS_CLIENT_SRC}
    ${INDICATORS_CLIENT_HEADERS}
)

include_directories(
    ${CMAKE_BINARY_DIR}
)

qt5_use_modules(${INDICATORS_CLIENT_APP} Core Widgets Quick)
set_target_properties(${INDICATORS_CLIENT_APP} PROPERTIES COMPILE_FLAGS -fPIC)

install(TARGETS ${INDICATORS_CLIENT_APP}
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
