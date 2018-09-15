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

target_link_libraries(${INDICATORS_CLIENT_APP} Qt5::Core Qt5::Widgets Qt5::Quick)

install(TARGETS ${INDICATORS_CLIENT_APP}
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
