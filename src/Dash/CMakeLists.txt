set(DASH_SRCS
    main.cpp
    ../ApplicationArguments.cpp
    ../MouseTouchAdaptor.cpp
    ../CachingNetworkManagerFactory.cpp
)

add_executable(unity8-dash ${DASH_SRCS})

qt5_use_modules(unity8-dash Gui Qml Quick Test)

pkg_check_modules(NEEDED_LIBS REQUIRED xcb libandroid-properties)
if (NOT "${NEEDED_LIBS_INCLUDE_DIRS}" STREQUAL "")
    set_target_properties(unity8-dash PROPERTIES INCLUDE_DIRECTORIES ${NEEDED_LIBS_INCLUDE_DIRS})
endif()
target_link_libraries(unity8-dash ${NEEDED_LIBS_LDFLAGS})

# For it to find libUbuntuGestures.so, needed by Ubuntu.Gestures QML module.
set_target_properties(unity8-dash PROPERTIES INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/${SHELL_PRIVATE_LIBDIR}")

target_link_libraries(unity8-dash UbuntuGestures connectivity-qt1)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fvisibility=hidden")

# install binaries
install(TARGETS ${DASH_APP}
     RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
