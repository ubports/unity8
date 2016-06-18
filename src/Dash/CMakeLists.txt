set(DASH_SRCS
    main.cpp
    ../CachingNetworkManagerFactory.cpp
    ../UnixSignalHandler.cpp
)

if (ENABLE_TOUCH_EMULATION)
    set(DASH_SRCS ${DASH_SRCS} ../MouseTouchAdaptor.cpp)
endif()

add_executable(unity8-dash ${DASH_SRCS})

qt5_use_modules(unity8-dash DBus Gui Qml Quick Test)

# For it to find libUbuntuGestures.so, needed by Ubuntu.Gestures QML module.
set_target_properties(unity8-dash PROPERTIES INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/${SHELL_PRIVATE_LIBDIR}")

target_link_libraries(unity8-dash UbuntuGestures connectivity-qt1)

if (ENABLE_TOUCH_EMULATION)
    target_link_libraries(unity8-dash ${MOUSETOUCHADAPTOR_LIBS_LDFLAGS})
endif()

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fvisibility=hidden")

# install binaries
install(TARGETS ${DASH_APP}
     RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
