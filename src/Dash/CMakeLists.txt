set(DASH_SRCS
    main.cpp
    ../ApplicationArguments.h
    ../MouseTouchAdaptor.cpp
    ../CachingNetworkManagerFactory.cpp
)

add_executable(unity8-dash ${DASH_SRCS})

qt5_use_modules(unity8-dash Gui Qml Quick Test)

# For it to find libUbuntuGestures.so, needed by Ubuntu.Gestures QML module.
set_target_properties(unity8-dash PROPERTIES INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/${SHELL_PRIVATE_LIBDIR}")

# install binaries
install(TARGETS ${DASH_APP}
     RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
