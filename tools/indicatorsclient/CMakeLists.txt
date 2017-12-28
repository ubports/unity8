project(indicators_client)

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

qt5_use_modules(${INDICATORS_CLIENT_APP} Core Widgets Quick)

install(TARGETS ${INDICATORS_CLIENT_APP}
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
