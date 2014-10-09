set(DASH_SRCS
    main.cpp
    ../ApplicationArguments.h
    ../MouseTouchAdaptor.cpp
    ../CachingNetworkManagerFactory.cpp
)

add_executable(unity8-dash ${DASH_SRCS})

qt5_use_modules(unity8-dash Gui Qml Quick Test)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fvisibility=hidden")

# install binaries
install(TARGETS ${DASH_APP}
     RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
