set(DASH_SRCS
    main.cpp
)

add_executable(unity8-dash ${DASH_SRCS})

qt5_use_modules(unity8-dash Gui Qml Quick Test)

# install binaries
install(TARGETS ${DASH_APP}
     RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
